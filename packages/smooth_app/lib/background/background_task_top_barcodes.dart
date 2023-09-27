import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_download_products.dart';
import 'package:smooth_app/background/background_task_progressing.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background progressing task about downloading top n barcodes.
class BackgroundTaskTopBarcodes extends BackgroundTaskProgressing {
  BackgroundTaskTopBarcodes._({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required super.work,
    required super.pageSize,
    required super.totalSize,
    required this.pageNumber,
  });

  BackgroundTaskTopBarcodes.fromJson(Map<String, dynamic> json)
      : pageNumber = json[_jsonTagPageNumber] as int? ?? 1,
        super.fromJson(json);

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
    final int pageNumber = 1,
  }) async {
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      totalSize: totalSize,
      soFarSize: soFarSize,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
      work,
      pageSize,
      totalSize,
      pageNumber,
    );
    await task.addToManager(localDatabase);
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
  ) =>
      BackgroundTaskTopBarcodes._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry().offTag,
        stamp: ';offlineBarcodes;$work',
        work: work,
        pageSize: pageSize,
        totalSize: totalSize,
        pageNumber: pageNumber,
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  bool get hasImmediateNextTask => true;

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
      ProductQuery.getUser(),
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
      );
    }
  }
}
