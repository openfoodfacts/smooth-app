import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';

/// Refreshes a product on the BE then on the local database.
class ProductRefresher {
  Future<bool> saveAndRefresh({
    required final BuildContext context,
    required final LocalDatabase localDatabase,
    required final Product product,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final bool? savedAndRefreshed = await LoadingDialog.run<bool>(
      future: _saveAndRefresh(product, localDatabase),
      context: context,
      title: appLocalizations.nutrition_page_update_running,
    );
    if (savedAndRefreshed == null) {
      // probably the end user stopped the dialog
      return false;
    }
    if (!savedAndRefreshed) {
      await LoadingDialog.error(context: context);
      return false;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(appLocalizations.nutrition_page_update_done),
        actions: <SmoothActionButton>[
          SmoothActionButton(
            text: appLocalizations.okay,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    return true;
  }

  /// Saves a product on the BE and refreshes the local database
  Future<bool> _saveAndRefresh(
    final Product inputProduct,
    final LocalDatabase localDatabase,
  ) async {
    try {
      final Status status = await OpenFoodAPIClient.saveProduct(
        ProductQuery.getUser(),
        inputProduct,
      );
      if (status.error != null) {
        return false;
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
        return true;
      }
    } catch (e) {
      //
    }
    return false;
  }
}
