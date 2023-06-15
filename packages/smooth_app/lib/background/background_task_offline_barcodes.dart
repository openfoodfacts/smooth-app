import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_offline_products.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_full_refresh.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background subtask about pre-downloading top n barcodes.
class BackgroundTaskOfflineBarcodes extends BackgroundTask {
  BackgroundTaskOfflineBarcodes._({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
  });

  BackgroundTaskOfflineBarcodes.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static const OperationType _operationType = OperationType.offlineBarcodes;

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
      'Starting the download of the most popular barcodes'; // TODO(monsieurtanuki): localize  and add percentage

  static BackgroundTask _getNewTask(
    final String uniqueId,
  ) =>
      BackgroundTaskOfflineBarcodes._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: ';offlineBarcodes',
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
    final int soFar = await daoWorkBarcode.getCount(work);
    if (soFar < totalSize) {
      myPrint('getbarcodes');
      final bool finished = await _getBarcodes(localDatabase);
      if (!finished) {
        await BackgroundTaskOfflineBarcodes.addTask(
          localDatabase: localDatabase,
        );
      } else {
        await BackgroundTaskOfflineProducts.addTask(
          localDatabase: localDatabase,
        );
      }
    }
  }

  Future<bool> _getBarcodes(final LocalDatabase localDatabase) async {
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);
    final int soFar = await daoWorkBarcode.getCount(work);
    if (soFar >= totalSize) {
      // we're done!
      return true;
    }
    final int pageNumber = (soFar ~/ pageSize) + 1;
    myPrint('BEGIN page $pageNumber');
    final ProductSearchQueryConfiguration queryConfig =
        ProductSearchQueryConfiguration(
      fields: <ProductField>[ProductField.BARCODE],
      parametersList: <Parameter>[
        const PageSize(size: pageSize),
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
    if (searchResult.products != null) {
      final List<String> barcodes = <String>[];
      for (final Product product in searchResult.products!) {
        barcodes.add(product.barcode!);
      }
      await daoWorkBarcode.putAll(work, barcodes);
      final int andNow = await daoWorkBarcode.getCount(work);
      myPrint('and then: ${barcodes.length}');
      myPrint('which means: $andNow');
      myPrint('END page $pageNumber');
      return andNow >= totalSize;
    }
    return false;
  }
}
