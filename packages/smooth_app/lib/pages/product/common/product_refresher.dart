import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/ProductResultV3.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Refreshes a product on the BE then on the local database.
class ProductRefresher {
  /// Checks if the user is logged in and opens a "please log in" dialog if not.
  Future<bool> checkIfLoggedIn(final BuildContext context) async {
    if (ProductQuery.isLoggedIn()) {
      return true;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(appLocalizations.sign_in_mandatory),
        actionsAxis: Axis.vertical,
        positiveAction: SmoothActionButton(
          text: appLocalizations.sign_in,
          onPressed: () async {
            Navigator.of(context).pop(); // remove dialog
            await Navigator.of(
              context,
              rootNavigator: true,
            ).push<dynamic>(
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => const LoginPage(),
              ),
            );
          },
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
    return false;
  }

  /// Returns the standard configuration for barcode product query.
  ProductQueryConfiguration getBarcodeQueryConfiguration(
    final String barcode,
  ) =>
      ProductQueryConfiguration(
        barcode,
        fields: ProductQuery.fields,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
        version: ProductQuery.productQueryVersion,
      );

  /// Fetches the product from the server and refreshes the local database.
  ///
  /// Silent version.
  Future<Product?> silentFetchAndRefresh({
    required final String barcode,
    required final LocalDatabase localDatabase,
  }) async {
    final _MetaProductRefresher meta =
        await _fetchAndRefresh(localDatabase, barcode);
    return meta.product;
  }

  /// Fetches the product from the server and refreshes the local database.
  ///
  /// With a waiting dialog.
  Future<void> fetchAndRefresh({
    required final String barcode,
    required final State<StatefulWidget> widget,
    VoidCallback? onSuccessCallback,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final AppLocalizations appLocalizations =
        AppLocalizations.of(widget.context);
    final _MetaProductRefresher? fetchAndRefreshed =
        await LoadingDialog.run<_MetaProductRefresher>(
      future: _fetchAndRefresh(localDatabase, barcode),
      context: widget.context,
      title: appLocalizations.refreshing_product,
    );
    if (fetchAndRefreshed == null) {
      return;
    }
    if (!widget.mounted) {
      return;
    }
    if (fetchAndRefreshed.product == null) {
      await LoadingDialog.error(context: widget.context);
      return;
    }
    ScaffoldMessenger.of(widget.context).showSnackBar(
      SnackBar(
        content: Text(appLocalizations.product_refreshed),
        duration: SnackBarDuration.short,
      ),
    );

    onSuccessCallback?.call();
  }

  Future<_MetaProductRefresher> _fetchAndRefresh(
    final LocalDatabase localDatabase,
    final String barcode,
  ) async {
    try {
      // ignore: deprecated_member_use
      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
        getBarcodeQueryConfiguration(barcode),
      );
      if (result.product != null) {
        await DaoProduct(localDatabase).put(result.product!);
        localDatabase.upToDate.setLatestDownloadedProduct(result.product!);
        localDatabase.notifyListeners();
        return _MetaProductRefresher.product(result.product);
      }
      return const _MetaProductRefresher.error(null);
    } catch (e) {
      Logs.e('Refresh from server error', ex: e);
      return _MetaProductRefresher.error(e.toString());
    }
  }
}

class _MetaProductRefresher {
  const _MetaProductRefresher.error(this.error) : product = null;

  const _MetaProductRefresher.product(this.product) : error = null;

  final String? error;
  final Product? product;
}
