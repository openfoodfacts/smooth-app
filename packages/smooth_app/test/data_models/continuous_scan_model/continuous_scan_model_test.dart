import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_provider.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:sqflite/sqflite.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

const String _barcode = '12345678';

class _ProductDatabase extends Mock implements Database {
  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table != 'gzipped_product' || whereArgs?.contains(_barcode) != true) {
      return <Map<String, Object?>>[];
    }

    final Uint8List productJson = Uint8List.fromList(
      gzip.encode(
        utf8.encode(
          jsonEncode(
            Product(barcode: _barcode, statesTags: <String>[]).toJson(),
          ),
        ),
      ),
    );
    return <Map<String, Object?>>[
      <String, Object?>{
        'barcode': _barcode,
        'encoded_gzipped_json': productJson,
        'last_update': 0,
        'lc': 'en',
        'product_type': 'food',
      },
    ];
  }
}

class _TestLocalDatabase extends MockLocalDatabase {
  _TestLocalDatabase() {
    _upToDateProductList = UpToDateProductListProvider(this);
  }

  @override
  final Database database = _ProductDatabase();

  late final UpToDateProductListProvider _upToDateProductList;

  @override
  UpToDateProductListProvider get upToDateProductList => _upToDateProductList;

  @override
  void notifyListeners() {}
}

class _NotFoundHttpHelper extends HttpHelper {
  _NotFoundHttpHelper() : super.internal();

  @override
  Future<http.Response> doGetRequest(
    Uri uri, {
    required UriHelper uriHelper,
    User? user,
    String? bearerToken,
    bool addCookiesToHeader = false,
    bool addCredentialsToHeader = false,
  }) async => http.Response(
    '{"status":"failure","result":{"id":"product_not_found",'
    '"lc_name":"Product not found"}}',
    200,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferences userPreferences;
  late Directory testDirectory;
  late HttpHelper previousHttpHelper;
  late _TestLocalDatabase localDatabase;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    userPreferences = await UserPreferences.getUserPreferences();

    testDirectory = await Directory.systemTemp.createTemp(
      'continuous_scan_model_test',
    );
    Hive.init(testDirectory.path);

    localDatabase = _TestLocalDatabase();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    daoProductList.registerAdapter();
    await daoProductList.init();

    previousHttpHelper = HttpHelper.instance;
    HttpHelper.instance = _NotFoundHttpHelper();
    ProductQuery.setQueryType(userPreferences);
    ProductQuery.setLanguage(null, userPreferences, languageCode: 'en');
    await ProductQuery.setCountry(userPreferences, 'fr');
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'Smooth App test');
  });

  tearDownAll(() async {
    HttpHelper.instance = previousHttpHelper;
    await Hive.close();
    await testDirectory.delete(recursive: true);
  });

  setUp(() async {
    await userPreferences.setSaveScannedAndViewedProducts(true);
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    await daoProductList.clear(ProductList.scanSession());
    await daoProductList.clear(ProductList.scanHistory());
    await daoProductList.clear(ProductList.history());
  });

  test('scan session survives refresh when saving history is disabled', () async {
    await userPreferences.setSaveScannedAndViewedProducts(false);

    final ContinuousScanModel model = ContinuousScanModel();
    expect(await model.load(localDatabase), same(model));

    final Completer<void> productCached = Completer<void>();
    void listenForCachedProduct() {
      if (model.getBarcodeState(_barcode) == ScannedProductState.CACHED &&
          !productCached.isCompleted) {
        productCached.complete();
      }
    }

    model.addListener(listenForCachedProduct);
    addTearDown(() => model.removeListener(listenForCachedProduct));

    expect(await model.onScan(_barcode), isTrue);
    // wait for the model to report CACHED
    await productCached.future.timeout(const Duration(seconds: 5));

    expect(model.getBarcodeState(_barcode), ScannedProductState.CACHED);
    // reloads the scan session from storage, replacing the model’s barcodes with the cached list
    await model.refresh();

    expect(model.getBarcodes(), <String>[_barcode]);

    final DaoProductList daoProductList = DaoProductList(localDatabase);
    expect(await daoProductList.getLength(ProductList.scanHistory()), 0);
    expect(await daoProductList.getLength(ProductList.history()), 0);
  });
}
