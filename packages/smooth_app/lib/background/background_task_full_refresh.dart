import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_download_products.dart';
import 'package:smooth_app/background/background_task_paged.dart';
import 'package:smooth_app/background/background_task_progressing.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';

/// Background task about refreshing all the already downloaded products.
class BackgroundTaskFullRefresh extends BackgroundTaskPaged {
  BackgroundTaskFullRefresh._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    required super.pageSize,
  });

  BackgroundTaskFullRefresh.fromJson(super.json) : super.fromJson();

  static const OperationType _operationType = OperationType.fullRefresh;

  static Future<void> addTask({
    required final BuildContext context,
    required final int pageSize,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
      pageSize,
    );
    if (!context.mounted) {
      return;
    }
    await task.addToManager(localDatabase, context: context);
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      (
        appLocalizations.background_task_title_full_refresh,
        AlignmentDirectional.bottomCenter,
      );

  static BackgroundTaskFullRefresh _getNewTask(
    final String uniqueId,
    final int pageSize,
  ) =>
      BackgroundTaskFullRefresh._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        stamp: ';fullRefresh',
        pageSize: pageSize,
      );

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);

    await daoWorkBarcode
        .deleteWork(BackgroundTaskProgressing.workFreshWithoutKP);
    await daoWorkBarcode.deleteWork(BackgroundTaskProgressing.workFreshWithKP);

    // We separate the products into two lists, products with or without
    // knowledge panels
    final List<String> barcodes = await daoProduct.getAllKeys();
    final List<String> productsWithoutKP = <String>[];
    final List<String> productsWithKP = <String>[];
    for (final String barcode in barcodes) {
      if (await _shouldBeDownloadedWithoutKP(daoProduct, barcode)) {
        productsWithoutKP.add(barcode);
      } else {
        productsWithKP.add(barcode);
      }
    }
    await _startDownloadTask(
      barcodes: productsWithoutKP,
      work: BackgroundTaskProgressing.workFreshWithoutKP,
      localDatabase: localDatabase,
      downloadFlag: BackgroundTaskDownloadProducts.flagMaskExcludeKP,
    );
    await _startDownloadTask(
      barcodes: productsWithKP,
      work: BackgroundTaskProgressing.workFreshWithKP,
      localDatabase: localDatabase,
      downloadFlag: 0,
    );
  }

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  bool hasImmediateNextTask = false;

  /// Returns true if we should download data without KP.
  ///
  /// That happens in one case:
  /// * we already have a corresponding local product that does not have
  /// populated knowledge panel fields.
  static Future<bool> _shouldBeDownloadedWithoutKP(
    final DaoProduct daoProduct,
    final String barcode,
  ) async {
    final Product? product = await daoProduct.get(barcode);
    return product != null && product.knowledgePanels == null;
  }

  Future<void> _startDownloadTask({
    required final List<String> barcodes,
    required final String work,
    required final LocalDatabase localDatabase,
    required final int downloadFlag,
  }) async {
    if (barcodes.isEmpty) {
      return;
    }
    hasImmediateNextTask = true;
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);
    await daoWorkBarcode.putAll(work, barcodes);
    await BackgroundTaskDownloadProducts.addTask(
      localDatabase: localDatabase,
      work: work,
      pageSize: pageSize,
      totalSize: barcodes.length,
      soFarSize: 0,
      downloadFlag: downloadFlag,
    );
  }
}
