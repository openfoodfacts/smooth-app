import 'dart:convert';

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
  });

  BackgroundTaskTopBarcodes.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static const OperationType _operationType = OperationType.offlineBarcodes;

  static Future<void> addTask({
    required final LocalDatabase localDatabase,
    required final String work,
    required final int pageSize,
    required final int totalSize,
    required final int soFarSize,
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
    );
    await task.addToManager(localDatabase);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) => null;

  static BackgroundTask _getNewTask(
    final String uniqueId,
    final String work,
    final int pageSize,
    final int totalSize,
  ) =>
      BackgroundTaskTopBarcodes._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: ';offlineBarcodes;$work',
        work: work,
        pageSize: pageSize,
        totalSize: totalSize,
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  bool get hasImmediateNextTask => true;

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);
    final int soFarBefore = await daoWorkBarcode.getCount(work);
    if (soFarBefore >= totalSize) {
      // not likely
      return;
    }
    final bool ok = await _getBarcodes(localDatabase);
    if (!ok) {
      // something failed, let's get out of here.
      return;
    }
    final int soFarAfter = await daoWorkBarcode.getCount(work);
    if (soFarAfter < totalSize) {
      await addTask(
        localDatabase: localDatabase,
        work: work,
        pageSize: pageSize,
        totalSize: totalSize,
        soFarSize: soFarAfter,
      );
    } else {
      await BackgroundTaskDownloadProducts.addTask(
        localDatabase: localDatabase,
        work: work,
        pageSize: pageSize,
        totalSize: totalSize,
        soFarSize: 0,
        downloadFlag: BackgroundTaskDownloadProducts.flagMaskExcludeKP,
      );
    }
  }

  /// Returns true if somehow we can go on with the process.
  Future<bool> _getBarcodes(final LocalDatabase localDatabase) async {
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);
    final int soFar = await daoWorkBarcode.getCount(work);
    if (soFar >= totalSize) {
      // we're done!
      return true;
    }
    final int pageNumber = (soFar ~/ pageSize) + 1;
    final ProductSearchQueryConfiguration queryConfig =
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
    );
    final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
      ProductQuery.getUser(),
      queryConfig,
    );
    if (searchResult.products == null) {
      // not expected
      return false;
    }
    final List<String> barcodes = <String>[];
    for (final Product product in searchResult.products!) {
      barcodes.add(product.barcode!);
    }
    await daoWorkBarcode.putAll(work, barcodes);
    return true;
  }
}
