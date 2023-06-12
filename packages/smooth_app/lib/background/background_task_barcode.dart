import 'package:flutter/foundation.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

/// Abstract background task that involves a single barcode.
abstract class BackgroundTaskBarcode extends BackgroundTask {
  const BackgroundTaskBarcode({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.barcode,
  });

  BackgroundTaskBarcode.fromJson(Map<String, dynamic> json)
      : barcode = json[_jsonTagBarcode] as String,
        super.fromJson(json);

  final String barcode;

  static const String _jsonTagBarcode = 'barcode';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagBarcode] = barcode;
    return result;
  }

  /// Uploads data changes.
  @protected
  Future<void> upload();

  /// Executes the background task: upload, download, update locally.
  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    await upload();
    await _downloadAndRefresh(localDatabase);
  }

  /// Downloads the whole product, updates locally.
  Future<void> _downloadAndRefresh(final LocalDatabase localDatabase) async =>
      ProductRefresher().silentFetchAndRefresh(
        barcode: barcode,
        localDatabase: localDatabase,
      );
}
