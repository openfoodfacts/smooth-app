import 'package:flutter/painting.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Background task that triggers a product refresh "a bit later".
///
/// Typical use-case is after uploading an image. It takes roughly 10 minutes
/// before Robotoff provides new questions: we should then refresh the product.
/// cf. https://github.com/openfoodfacts/smooth-app/issues/3380
class BackgroundTaskRefreshLater extends BackgroundTaskBarcode {
  BackgroundTaskRefreshLater._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.productType,
    required super.stamp,
    required this.timestamp,
  });

  BackgroundTaskRefreshLater.fromJson(super.json)
    : timestamp = json[_jsonTagTimestamp] as int,
      super.fromJson();

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
    required final ProductType productType,
  }) async {
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      barcode,
      uniqueId,
      productType,
    );
    await task.addToManager(localDatabase, queue: BackgroundTaskQueue.fast);
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
    final AppLocalizations appLocalizations,
  ) => null;

  /// Returns a new background task about refreshing a product later.
  static BackgroundTaskRefreshLater _getNewTask(
    final String barcode,
    final String uniqueId,
    final ProductType productType,
  ) => BackgroundTaskRefreshLater._(
    uniqueId: uniqueId,
    processName: _operationType.processName,
    barcode: barcode,
    productType: productType,
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
