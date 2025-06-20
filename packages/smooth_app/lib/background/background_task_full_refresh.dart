import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_download_products.dart';
import 'package:smooth_app/background/background_task_paged.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/background/work_type.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

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
    await task.addToManager(
      localDatabase,
      context: context,
      queue: BackgroundTaskQueue.longHaul,
    );
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

    for (final ProductType productType in ProductType.values) {
      await daoWorkBarcode.deleteWork(
        WorkType.freshKP.getWorkTag(productType),
      );
      await daoWorkBarcode.deleteWork(
        WorkType.freshNoKP.getWorkTag(productType),
      );
    }

    // We separate the products into lists, products with or without
    // knowledge panels, and split by product types.
    final Map<String, List<String>> split = await daoProduct.splitAllProducts(
      (Product product) {
        final bool noKP = product.knowledgePanels == null;
        final WorkType workType = noKP ? WorkType.freshNoKP : WorkType.freshKP;
        final ProductType productType = product.productType ?? ProductType.food;
        return workType.getWorkTag(productType);
      },
    );
    for (int i = 0; i <= 1; i++) {
      final bool noKP = i == 0;
      final WorkType workType = noKP ? WorkType.freshNoKP : WorkType.freshKP;
      for (final ProductType productType in ProductType.values) {
        final String tag = workType.getWorkTag(productType);
        final List<String>? barcodes = split[tag];
        if (barcodes == null) {
          continue;
        }
        await _startDownloadTask(
          barcodes: barcodes,
          work: tag,
          localDatabase: localDatabase,
          downloadFlag:
              noKP ? BackgroundTaskDownloadProducts.flagMaskExcludeKP : 0,
          productType: productType,
        );
      }
    }
  }

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  bool hasImmediateNextTask = false;

  Future<void> _startDownloadTask({
    required final List<String> barcodes,
    required final String work,
    required final LocalDatabase localDatabase,
    required final int downloadFlag,
    required final ProductType productType,
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
      productType: productType,
    );
  }
}
