import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task that triggers a product refresh "a bit later".
///
/// Typical use-case is after uploading an image. It takes roughly 10 minutes
/// before Robotoff provides new questions: we should then refresh the product.
/// cf. https://github.com/openfoodfacts/smooth-app/issues/3380
class BackgroundTaskRefreshLater extends BackgroundTaskBarcode {
  const BackgroundTaskRefreshLater._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.timestamp,
  });

  BackgroundTaskRefreshLater.fromJson(Map<String, dynamic> json)
      : timestamp = json[_jsonTagTimestamp] as int,
        super.fromJson(json);

  static const String _jsonTagTimestamp = 'timestamp';

  static const OperationType _operationType = OperationType.refreshLater;

  /// Delay in milliseconds.
  ///
  /// To be used as a delay between the task creation and its activation.
  static const int _delay = 10 * 60 * 1000;

  /// Timestamp when the task was created, in millis.
  final int timestamp;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagTimestamp] = timestamp;
    return result;
  }

  /// Here we change nothing, therefore we do nothing.
  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  /// Adds the background task about refreshing the product later.
  static Future<void> addTask(
    final String barcode, {
    required final LocalDatabase localDatabase,
  }) async {
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(barcode, uniqueId);
    await task.addToManager(localDatabase);
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      null;

  /// Returns a new background task about refreshing a product later.
  static BackgroundTaskRefreshLater _getNewTask(
    final String barcode,
    final String uniqueId,
  ) =>
      BackgroundTaskRefreshLater._(
        uniqueId: uniqueId,
        processName: _operationType.processName,
        barcode: barcode,
        languageCode: ProductQuery.getLanguage().code,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry().offTag,
        timestamp: LocalDatabase.nowInMillis(),
        stamp: _getStamp(barcode),
      );

  static String _getStamp(final String barcode) => '$barcode;refresh';

  /// Here we change nothing, therefore we do nothing.
  @override
  Future<void> upload() async {}

  /// Returns true if "enough" time elapsed after the task creation.
  @override
  bool mayRunNow() => LocalDatabase.nowInMillis() - timestamp > _delay;
}
