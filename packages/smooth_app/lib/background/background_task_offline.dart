import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_progressing.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/background_task_top_barcodes.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/background/work_type.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';

/// Main background task about pre-downloading top n products for offline usage.
class BackgroundTaskOffline extends BackgroundTaskProgressing {
  BackgroundTaskOffline._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    required super.work,
    required super.pageSize,
    required super.totalSize,
    required super.productType,
  });

  BackgroundTaskOffline.fromJson(super.json) : super.fromJson();

  static const OperationType _operationType = OperationType.offline;

  static Future<void> addTask({
    required final BuildContext context,
    required final int pageSize,
    required final int totalSize,
    required final ProductType productType,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      totalSize: totalSize,
      soFarSize: 0,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
      WorkType.offline.getWorkTag(productType),
      pageSize,
      totalSize,
      productType,
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
        appLocalizations.background_task_title_top_n,
        AlignmentDirectional.bottomCenter,
      );

  static BackgroundTaskOffline _getNewTask(
    final String uniqueId,
    final String work,
    final int pageSize,
    final int totalSize,
    final ProductType productType,
  ) =>
      BackgroundTaskOffline._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        stamp: ';offline',
        work: work,
        pageSize: pageSize,
        totalSize: totalSize,
        productType: productType,
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  bool get hasImmediateNextTask => true;

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final DaoWorkBarcode daoWorkBarcode = DaoWorkBarcode(localDatabase);
    await daoWorkBarcode.deleteWork(work);
    await BackgroundTaskTopBarcodes.addTask(
      localDatabase: localDatabase,
      work: work,
      pageSize: pageSize,
      totalSize: totalSize,
      soFarSize: 0,
      productType: productType,
    );
  }
}
