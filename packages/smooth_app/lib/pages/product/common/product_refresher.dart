import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';

/// Refreshes a product on the BE then on the local database.
class ProductRefresher {
  /// Returns a saved and refreshed [Product] if successful, or null.
  Future<Product?> saveAndRefresh({
    required final BuildContext context,
    required final LocalDatabase localDatabase,
    required final Product product,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final _MetaProductRefresher? savedAndRefreshed =
        await LoadingDialog.run<_MetaProductRefresher>(
      future: _saveAndRefresh(product, localDatabase),
      context: context,
      title: appLocalizations.nutrition_page_update_running,
    );
    if (savedAndRefreshed == null) {
      // probably the end user stopped the dialog
      return null;
    }
    if (savedAndRefreshed.product == null) {
      await LoadingDialog.error(context: context);
      return null;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(appLocalizations.nutrition_page_update_done),
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
    return savedAndRefreshed.product;
  }

  /// Saves a product on the BE and refreshes the local database
  Future<_MetaProductRefresher> _saveAndRefresh(
    final Product inputProduct,
    final LocalDatabase localDatabase,
  ) async {
    try {
      final Status status = await OpenFoodAPIClient.saveProduct(
        ProductQuery.getUser(),
        inputProduct,
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
}

class _MetaProductRefresher {
  const _MetaProductRefresher.error(this.error) : product = null;
  const _MetaProductRefresher.product(this.product) : error = null;

  final String? error;
  final Product? product;
}
