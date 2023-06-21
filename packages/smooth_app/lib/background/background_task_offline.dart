import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_progressing.dart';
import 'package:smooth_app/background/background_task_top_barcodes.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Main background task about pre-downloading top n products for offline usage.
class BackgroundTaskOffline extends BackgroundTaskProgressing {
  BackgroundTaskOffline._({
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

  BackgroundTaskOffline.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static const OperationType _operationType = OperationType.offline;

  static Future<void> addTask({
    required final State<StatefulWidget> widget,
    required final int pageSize,
    required final int totalSize,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      totalSize: totalSize,
      soFarSize: 0,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
      BackgroundTaskProgressing.workOffline,
      pageSize,
      totalSize,
    );
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      appLocalizations.background_task_title_top_n;

  static BackgroundTaskOffline _getNewTask(
    final String uniqueId,
    final String work,
    final int pageSize,
    final int totalSize,
  ) =>
      BackgroundTaskOffline._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: ';offline',
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
    await daoWorkBarcode.deleteWork(work);
    await BackgroundTaskTopBarcodes.addTask(
      localDatabase: localDatabase,
      work: work,
      pageSize: pageSize,
      totalSize: totalSize,
      soFarSize: 0,
    );
  }
}
