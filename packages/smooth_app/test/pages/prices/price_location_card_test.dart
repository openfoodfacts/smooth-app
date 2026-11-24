import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/prices/price_location_card.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../tests_utils/mocks.dart';

class _MockDatabase extends Fake implements Database {
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
  }) async => <Map<String, Object?>>[];
}

class _TestLocalDatabase extends Fake implements LocalDatabase {
  _TestLocalDatabase(this.database);

  @override
  final Database database;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class _NoRiveFile implements FileLoader {
  @override
  Future<File> file() => Completer<File>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferences userPreferences;
  late Directory hiveDirectory;

  setUpAll(() async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    await mockMatomo();
    userPreferences = await UserPreferences.getUserPreferences();

    hiveDirectory = await Directory.systemTemp.createTemp(
      'price-location-card-test',
    );
    Hive.init(hiveDirectory.path);
    await Hive.openBox<List<String>>('stringList');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  testWidgets('prefills the location search with the saved city', (
    WidgetTester tester,
  ) async {
    await userPreferences.setUserCityOrPostcode('Paris');

    final Database database = _MockDatabase();
    final LocalDatabase localDatabase = _TestLocalDatabase(database);

    final ProductPreferences productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: userPreferences.setImportance,
        getImportance: userPreferences.getImportance,
        notify: () {},
      ),
    );
    await productPreferences.init(PlatformAssetBundle());
    final PriceModel priceModel = PriceModel(
      proofType: ProofType.receipt,
      currency: Currency.EUR,
      multipleProducts: false,
    );
    addTearDown(priceModel.dispose);

    bool locationChanged = false;
    await tester.pumpWidget(
      Provider<FileLoader>.value(
        value: _NoRiveFile(),
        child: MockSmoothApp(
          userPreferences,
          UserManagementProvider(),
          productPreferences,
          ThemeProvider(userPreferences),
          TextContrastProvider(userPreferences),
          ColorProvider(userPreferences),
          ChangeNotifierProvider<PriceModel>.value(
            value: priceModel,
            child: Scaffold(
              body: PriceLocationCard(
                onLocationChanged: (OsmLocation _) => locationChanged = true,
              ),
            ),
          ),
          localDatabase: localDatabase,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SmoothLargeButtonWithIcon), findsOneWidget);
    await tester.tap(find.byType(SmoothLargeButtonWithIcon));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Paris',
    );
    expect(locationChanged, isFalse);
  });
}
