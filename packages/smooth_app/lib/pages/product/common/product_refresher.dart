import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/query/product_query.dart';

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

  /// Fetches the product from the server and refreshes the local database.
  Future<void> fetchAndRefresh({
    required final String barcode,
    required final State<StatefulWidget> widget,
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
    localDatabase.upToDate
        .setLatestDownloadedProduct(fetchAndRefreshed.product!);
    ScaffoldMessenger.of(widget.context).showSnackBar(
      SnackBar(
        content: Text(appLocalizations.product_refreshed),
        duration: SnackBarDuration.short,
      ),
    );
  }

  Future<_MetaProductRefresher> _fetchAndRefresh(
    final LocalDatabase localDatabase,
    final String barcode,
  ) async {
    try {
      final ProductQueryConfiguration configuration = ProductQueryConfiguration(
        barcode,
        fields: ProductQuery.fields,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
      );
      final ProductResult result = await OpenFoodAPIClient.getProduct(
        configuration,
      );
      if (result.product != null) {
        await DaoProduct(localDatabase).put(result.product!);
        localDatabase.notifyListeners();
        return _MetaProductRefresher.product(result.product);
      }
      return const _MetaProductRefresher.error(null);
    } catch (e) {
      // TODO(monsieurtanuki): add call to Logs
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
