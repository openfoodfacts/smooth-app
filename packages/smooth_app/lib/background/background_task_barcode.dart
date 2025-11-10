import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_floating_message.dart';

/// Abstract background task that involves a single barcode.
abstract class BackgroundTaskBarcode extends BackgroundTask {
  BackgroundTaskBarcode({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    required this.barcode,
    required this.productType,
    super.language,
  });

  BackgroundTaskBarcode.fromJson(super.json)
    : barcode = json[_jsonTagBarcode] as String,
      productType =
          ProductType.fromOffTag(json[_jsonTagProductType] as String?) ??
          // for legacy reason (not refreshed products = no product type)
          ProductType.food,
      super.fromJson();

  final String barcode;
  final ProductType productType;

  static const String _jsonTagBarcode = 'barcode';
  static const String _jsonTagProductType = 'productType';

  // cf. https://github.com/openfoodfacts/smooth-app/issues/7103
  static const List<String> _forbiddenProducts = <String>[
    '93270067481501',
    '093270067481501',
  ];

  static bool isBarcodeToBeIgnored(
    final String barcode,
    final BuildContext? context,
  ) {
    final bool result = _forbiddenProducts.contains(barcode);
    if (result && context != null) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      SmoothFloatingMessage(
        message: appLocalizations.onboarding_welcome_warning,
        type: SmoothFloatingMessageType.warning,
      ).show(
        context,
        duration: SnackBarDuration.medium,
        alignment: AlignmentDirectional.bottomCenter,
      );
    }
    return result;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagBarcode] = barcode;
    result[_jsonTagProductType] = productType.offTag;
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

  @protected
  UriProductHelper get uriProductHelper =>
      ProductQuery.getUriProductHelper(productType: productType);
}
