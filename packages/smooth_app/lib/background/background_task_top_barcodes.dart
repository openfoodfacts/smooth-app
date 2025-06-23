import 'package:flutter/painting.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_download_products.dart';
import 'package:smooth_app/background/background_task_progressing.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/query/search_products_manager.dart';

/// Background progressing task about downloading top n barcodes.
class BackgroundTaskTopBarcodes extends BackgroundTaskProgressing {
  BackgroundTaskTopBarcodes._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    required super.work,
    required super.pageSize,
    required super.totalSize,
    required super.productType,
    required this.pageNumber,
  });

  BackgroundTaskTopBarcodes.fromJson(super.json)
      : pageNumber = json[_jsonTagPageNumber] as int? ?? 1,
        super.fromJson();

  final int pageNumber;

  static const String _jsonTagPageNumber = 'pageNumber';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagPageNumber] = pageNumber;
    return result;
  }

  static const OperationType _operationType = OperationType.offlineBarcodes;

  static Future<void> addTask({
    required final LocalDatabase localDatabase,
    required final String work,
    required final int pageSize,
    required final int totalSize,
    required final int soFarSize,
    required final ProductType productType,
    final int pageNumber = 1,
  }) async {
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      totalSize: totalSize,
      soFarSize: soFarSize,
      productType: productType,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
      work,
      pageSize,
      totalSize,
      pageNumber,
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
    final int pageNumber,
    final ProductType productType,
  ) =>
      BackgroundTaskTopBarcodes._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        stamp: ';offlineBarcodes;$work',
        work: work,
        pageSize: pageSize,
        totalSize: totalSize,
        pageNumber: pageNumber,
        productType: productType,
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  bool get hasImmediateNextTask => true;

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final SearchResult searchResult =
        await SearchProductsManager.searchProducts(
      ProductQuery.getReadUser(),
      ProductSearchQueryConfiguration(
        fields: <ProductField>[ProductField.BARCODE],
        parametersList: <Parameter>[
          PageSize(size: pageSize),
          PageNumber(page: pageNumber),
          const SortBy(option: SortOption.POPULARITY),
        ],
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
        version: ProductQuery.productQueryVersion,
      ),
      uriHelper: uriProductHelper,
      type: SearchProductsType.background,
    );
    if (searchResult.products == null || searchResult.count == null) {
      throw Exception('Cannot download top barcodes');
    }
    int newTotalSize = searchResult.count!;
    if (newTotalSize > totalSize) {
      newTotalSize = totalSize;
    }
    final Set<String> barcodes = <String>{};
    for (final Product product in searchResult.products!) {
      barcodes.add(product.barcode!);
    }
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);
    await daoWorkBarcode.putAll(work, barcodes);
    // if we haven't downloaded a full page, it means that there's no data left.
    final bool fullPageDownloaded = barcodes.length == pageSize;
    final int soFarAfter = await daoWorkBarcode.getCount(work);
    if (soFarAfter < newTotalSize && fullPageDownloaded) {
      // we still have barcodes to download
      await addTask(
        localDatabase: localDatabase,
        work: work,
        pageSize: pageSize,
        totalSize: newTotalSize,
        soFarSize: soFarAfter,
        pageNumber: pageNumber + 1,
        productType: productType,
      );
    } else {
      // we have all the barcodes; now we need to download the products.
      await BackgroundTaskDownloadProducts.addTask(
        localDatabase: localDatabase,
        work: work,
        pageSize: pageSize,
        totalSize: soFarAfter,
        soFarSize: 0,
        downloadFlag: BackgroundTaskDownloadProducts.flagMaskExcludeKP,
        productType: productType,
      );
    }
  }
}
