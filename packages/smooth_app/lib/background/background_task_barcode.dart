import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';
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
  Future<void> upload(final LocalDatabase localDatabase);

  /// Executes the background task: upload, download, update locally.
  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    bool exception = false;
    try {
      await upload(localDatabase);
    } catch (e) {
      exception = true;
      rethrow;
    } finally {
      if (refreshAfterException || !exception) {
        await _downloadAndRefresh(localDatabase);
      }
    }
  }

  /// Should we refresh the product data after an exception?
  ///
  /// We need to refresh the product when the upload is successful, in order to
  /// retrieve the latest data, including the changes.
  /// But in some cases, we also need to refresh if the upload failed.
  /// The typical use-case is when the local product_type is incorrect.
  /// That means calling the wrong server for write operations, and that always
  /// fails. If we refresh the product from the server, we get the correct
  /// product type, and therefore the correct server to call.
  /// We refresh the product AFTER a failing "upload", so that the NEXT
  /// occurrence of the same background task takes the correct product type into
  /// account.
  ///
  /// Some background tasks never care about the product type, and can return
  /// false.
  @protected
  bool get refreshAfterException => true;

  /// Downloads the whole product, updates locally.
  Future<void> _downloadAndRefresh(final LocalDatabase localDatabase) async =>
      ProductRefresher().silentFetchAndRefresh(
        barcode: barcode,
        localDatabase: localDatabase,
      );

  @protected
  Future<UriProductHelper> getUriProductHelper(
    final LocalDatabase localDatabase,
  ) async {
    // in case the product type evolved (very rare cases), we need to check it
    // and use the correct product type instead.
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final Product? product = await daoProduct.get(barcode);
    final ProductType? databaseProductType = product?.productType;
    final ProductType bestProductType = databaseProductType ?? productType;
    if (databaseProductType != null && databaseProductType != productType) {
      Logs.w(
        'Product type change for $barcode'
        ': $productType expected'
        ', $databaseProductType from database',
      );
    }
    return ProductQuery.getUriProductHelper(productType: bestProductType);
  }
}
