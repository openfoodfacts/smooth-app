import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_full_refresh.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background subtask about downloading products.
///
/// For space reasons, we don't download the full products: we remove the
/// knowledge panel fields.
class BackgroundTaskOfflineProducts extends BackgroundTask {
  BackgroundTaskOfflineProducts._({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
  });

  BackgroundTaskOfflineProducts.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static const OperationType _operationType = OperationType.offlineProducts;

  static Future<void> addTask({
    required final LocalDatabase localDatabase,
  }) async {
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      BackgroundTaskFullRefresh.noBarcode,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
    );
    await task.addToManager(localDatabase);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      'Starting the download of the most popular products'; // TODO(monsieurtanuki): localize and add percentage

  static BackgroundTask _getNewTask(
    final String uniqueId,
  ) =>
      BackgroundTaskOfflineProducts._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: ';offlineProducts',
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  void myPrint(final String message) =>
      print('${LocalDatabase.nowInMillis()}: $message');

  static const String work = 'O';
  static const int pageSize = 100;
  static const int totalSize = 500;

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);
    myPrint('DOWNLOAD barcodes');
    final List<String> barcodes = await daoWorkBarcode.getNextPage(
      work,
      pageSize,
    );
    if (barcodes.isEmpty) {
      // we're done!
      return;
    }
    final List<ProductField> fields = List<ProductField>.from(
      ProductQuery.fields,
      growable: true,
    );
    fields.remove(ProductField.KNOWLEDGE_PANELS);
    final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
      ProductQuery.getUser(),
      ProductSearchQueryConfiguration(
        fields: fields,
        parametersList: <Parameter>[
          const PageSize(size: pageSize),
          const PageNumber(page: 1),
          BarcodeParameter.list(barcodes),
        ],
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
        version: ProductQuery.productQueryVersion,
        // https://fr.openfoodfacts.org/api/v2/search?page_size=1000&fields=code
      ),
    );
    final List<Product>? downloadedProducts = searchResult.products;
    if (downloadedProducts == null) {
      myPrint('not supposed to happen!!!');
      // TODO: not supposed to happen
      return;
    }
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    for (final Product product in downloadedProducts) {
      if (await _shouldBeUpdated(daoProduct, product.barcode!)) {
        await daoProduct.put(product);
        myPrint('added ${product.barcode}');
      }
    }
    await daoWorkBarcode.deleteBarcodes(work, barcodes);
    final int remaining = await daoWorkBarcode.getCount(work);
    if (remaining > 0) {
      await addTask(localDatabase: localDatabase);
    }
  }

  /// Returns true if we should save the downloaded data into the local db.
  ///
  /// That happens in two cases:
  /// * we don't have a corresponding local product yet
  /// * the product we already have locally does not have populated knowledge
  /// panel fields (therefore we won't "erase" any local KP data)
  static Future<bool> _shouldBeUpdated(
    final DaoProduct daoProduct,
    final String barcode,
  ) async {
    final Product? product = await daoProduct.get(barcode);
    return product == null || product.knowledgePanels == null;
  }
}
