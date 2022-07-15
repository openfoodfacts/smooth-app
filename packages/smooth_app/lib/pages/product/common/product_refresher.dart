import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
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

  /// Returns true if successfully saved and refreshed a [Product].
  Future<bool> saveAndRefresh({
    required final BuildContext context,
    required final LocalDatabase localDatabase,
    required final Product product,
    // most of the time, we need the user to be signed in.
    final bool isLoggedInMandatory = true,
  }) async {
    final UpToDateProductProvider provider =
        context.read<UpToDateProductProvider>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (isLoggedInMandatory) {
      if (!await checkIfLoggedIn(context)) {
        return false;
      }
    }
    final _MetaProductRefresher? savedAndRefreshed =
        await LoadingDialog.run<_MetaProductRefresher>(
      future: _saveAndRefresh(product, localDatabase),
      context: context,
      title: appLocalizations
          .nutrition_page_update_running, // TODO(monsieurtanuki): title as method parameter
    );
    if (savedAndRefreshed == null) {
      // probably the end user stopped the dialog
      return false;
    }
    if (savedAndRefreshed.product == null) {
      await LoadingDialog.error(context: context);
      return false;
    }
    provider.set(savedAndRefreshed.product!);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(appLocalizations
            .nutrition_page_update_done), // TODO(monsieurtanuki): title as method parameter
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
    return true;
  }

  // TODO(monsieurtanuki): reuse _refresh
  // TODO(monsieurtanuki): check if try/catch is appropriate
  /// Saves a product on the BE and refreshes the local database
  Future<_MetaProductRefresher> _saveAndRefresh(
    final Product inputProduct,
    final LocalDatabase localDatabase,
  ) async {
    try {
      final Status status = await OpenFoodAPIClient.saveProduct(
        ProductQuery.getUser(),
        inputProduct,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
      );
      if (status.error != null) {
        return _MetaProductRefresher.error(status.error);
      }
      final ProductQueryConfiguration configuration = ProductQueryConfiguration(
        inputProduct.barcode!,
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
    } catch (e) {
      //
    }
    return const _MetaProductRefresher.error(null);
  }

  Future<bool> fetchAndRefresh({
    required final BuildContext context,
    required final LocalDatabase localDatabase,
    required final String barcode,
  }) async {
    final UpToDateProductProvider provider =
        context.read<UpToDateProductProvider>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final _MetaProductRefresher? fetchAndRefreshed =
        await LoadingDialog.run<_MetaProductRefresher>(
      future: _fetchAndRefresh(localDatabase, barcode),
      context: context,
      title: appLocalizations.refreshing_product,
    );
    if (fetchAndRefreshed == null) {
      return false;
    }
    if (fetchAndRefreshed.product == null) {
      await LoadingDialog.error(context: context);
      return false;
    }
    provider.set(fetchAndRefreshed.product!);
    return true;
  }

  Future<_MetaProductRefresher> _fetchAndRefresh(
    final LocalDatabase localDatabase,
    final String barcode,
  ) async {
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
  }
}

class _MetaProductRefresher {
  const _MetaProductRefresher.error(this.error) : product = null;
  const _MetaProductRefresher.product(this.product) : error = null;

  final String? error;
  final Product? product;
}
