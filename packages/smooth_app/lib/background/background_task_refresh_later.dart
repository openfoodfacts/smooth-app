import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task that triggers a product refresh "a bit later".
///
/// Typical use-case is after uploading an image. It takes roughly 10 minutes
/// before Robotoff provides new questions: we should then refresh the product.
/// cf. https://github.com/openfoodfacts/smooth-app/issues/3380
class BackgroundTaskRefreshLater extends AbstractBackgroundTask {
  const BackgroundTaskRefreshLater._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required this.timestamp,
  });

  BackgroundTaskRefreshLater._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          timestamp: json['timestamp'] as int,
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'PRODUCT_REFRESH_LATER';

  static const OperationType _operationType = OperationType.refreshLater;

  /// Delay in milliseconds.
  ///
  /// To be used as a delay between the task creation and its activation.
  static const int _delay = 10 * 60 * 1000;

  /// Timestamp when the task was created, in millis.
  final int timestamp;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'timestamp': timestamp,
      };

  /// Returns the deserialized background task if possible, or null.
  static BackgroundTaskRefreshLater? fromJson(final Map<String, dynamic> map) {
    try {
      final BackgroundTaskRefreshLater result =
          BackgroundTaskRefreshLater._fromJson(map);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

  /// Here we change nothing, therefore we do nothing.
  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  /// Here we change nothing, therefore we do nothing.
  @override
  Future<void> postExecute(final LocalDatabase localDatabase) async {}

  /// Adds the background task about refreshing the product later.
  static Future<void> addTask(
    final String barcode, {
    required final LocalDatabase localDatabase,
  }) async {
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode,
    );
    final AbstractBackgroundTask task = _getNewTask(barcode, uniqueId);
    await task.addToManager(localDatabase);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) => null;

  /// Returns a new background task about refreshing a product later.
  static BackgroundTaskRefreshLater _getNewTask(
    final String barcode,
    final String uniqueId,
  ) =>
      BackgroundTaskRefreshLater._(
        uniqueId: uniqueId,
        processName: _PROCESS_NAME,
        barcode: barcode,
        languageCode: ProductQuery.getLanguage().code,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        timestamp: LocalDatabase.nowInMillis(),
      );

  /// Here we change nothing, therefore we do nothing.
  @override
  Future<void> upload() async {}

  /// Returns true if "enough" time elapsed after the task creation.
  @override
  bool mayRunNow() => LocalDatabase.nowInMillis() - timestamp > _delay;
}
