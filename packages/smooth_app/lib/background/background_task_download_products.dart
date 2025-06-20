import 'package:flutter/painting.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_progressing.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/query/search_products_manager.dart';

/// Background progressing task about downloading products.
class BackgroundTaskDownloadProducts extends BackgroundTaskProgressing {
  BackgroundTaskDownloadProducts._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    required super.work,
    required super.pageSize,
    required super.totalSize,
    required super.productType,
    required this.downloadFlag,
  });

  BackgroundTaskDownloadProducts.fromJson(super.json)
      : downloadFlag = json[_jsonTagDownloadFlag] as int,
        super.fromJson();

  /// Download flag. Normal case: 0, meaning all fields are downloaded.
  final int downloadFlag;

  /// Download flag mask: exclude the Knowledge Panels field from the download.
  static const int flagMaskExcludeKP = 1;

  static const String _jsonTagDownloadFlag = 'download_flag';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagDownloadFlag] = downloadFlag;
    return result;
  }

  static const OperationType _operationType = OperationType.offlineProducts;

  static Future<void> addTask({
    required final LocalDatabase localDatabase,
    required final String work,
    required final int pageSize,
    required final int totalSize,
    required final int soFarSize,
    required final int downloadFlag,
    required final ProductType productType,
  }) async {
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      soFarSize: soFarSize,
      totalSize: totalSize,
      work: work,
      productType: productType,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
      work,
      pageSize,
      totalSize,
      downloadFlag,
      productType,
    );
    await task.addToManager(
      localDatabase,
      queue: BackgroundTaskQueue.longHaul,
    );
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      null;

  static BackgroundTask _getNewTask(
    final String uniqueId,
    final String work,
    final int pageSize,
    final int totalSize,
    final int downloadFlag,
    final ProductType productType,
  ) =>
      BackgroundTaskDownloadProducts._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        stamp: ';offlineProducts;$work',
        work: work,
        pageSize: pageSize,
        totalSize: totalSize,
        downloadFlag: downloadFlag,
        productType: productType,
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  bool hasImmediateNextTask = false;

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);
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
    if (downloadFlag & flagMaskExcludeKP != 0) {
      fields.remove(ProductField.KNOWLEDGE_PANELS);
    }
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    final SearchResult searchResult =
        await SearchProductsManager.searchProducts(
      ProductQuery.getReadUser(),
      ProductSearchQueryConfiguration(
        fields: fields,
        parametersList: <Parameter>[
          PageSize(size: pageSize),
          const PageNumber(page: 1),
          BarcodeParameter.list(barcodes),
        ],
        language: language,
        country: ProductQuery.getCountry(),
        version: ProductQuery.productQueryVersion,
      ),
      uriHelper: uriProductHelper,
      type: SearchProductsType.background,
    );
    final List<Product>? downloadedProducts = searchResult.products;
    if (downloadedProducts == null) {
      throw Exception('Something bad happened downloading products');
    }
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    for (final Product product in downloadedProducts) {
      if (await _shouldBeUpdated(daoProduct, product.barcode!)) {
        await daoProduct.put(
          product,
          language,
          productType: productType,
        );
      }
    }
    final int deleted = await daoWorkBarcode.deleteBarcodes(work, barcodes);
    if (deleted == 0) {
      // for some reason, it's already been taken care of.
      return;
    }
    final int remaining = await daoWorkBarcode.getCount(work);
    if (remaining > 0) {
      hasImmediateNextTask = true;
      await addTask(
        localDatabase: localDatabase,
        work: work,
        pageSize: pageSize,
        totalSize: totalSize,
        soFarSize: totalSize - remaining,
        downloadFlag: downloadFlag,
        productType: productType,
      );
    }
  }

  /// Returns true if we should save the downloaded data into the local db.
  ///
  /// That happens in two cases:
  /// * we don't have a corresponding local product yet
  /// * the product we already have locally does not have populated knowledge
  /// panel fields (therefore we won't "erase" any local Knowledge Panels data)
  static Future<bool> _shouldBeUpdated(
    final DaoProduct daoProduct,
    final String barcode,
  ) async {
    final Product? product = await daoProduct.get(barcode);
    return product == null || product.knowledgePanels == null;
  }
}
