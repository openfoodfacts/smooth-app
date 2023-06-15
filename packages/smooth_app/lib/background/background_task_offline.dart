import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_offline_barcodes.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_full_refresh.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about pre-downloading top n products for offline usage.
///
/// For space reasons, we don't download the full products: we remove the
/// knowledge panel fields.
class BackgroundTaskOffline extends BackgroundTask {
  BackgroundTaskOffline._({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
  });

  BackgroundTaskOffline.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static const OperationType _operationType = OperationType.offline;

  static Future<void> addTask({
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      BackgroundTaskFullRefresh.noBarcode,
    );
    final BackgroundTask task = _getNewTask(
      uniqueId,
    );
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) =>
      'Starting the download of the most popular products'; // TODO(monsieurtanuki): localize

  static BackgroundTaskOffline _getNewTask(
    final String uniqueId,
  ) =>
      BackgroundTaskOffline._(
        processName: _operationType.processName,
        uniqueId: uniqueId,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: ';offline',
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
    await daoWorkBarcode.deleteWork(work);
    await BackgroundTaskOfflineBarcodes.addTask(localDatabase: localDatabase);
  }
}
