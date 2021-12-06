import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/barcode_product_query.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

/// Dialog helper for product barcode search
class ProductDialogHelper {
  ProductDialogHelper({
    required this.barcode,
    required this.context,
    required this.localDatabase,
    required this.refresh,
  });

  final String barcode;
  final BuildContext context;
  final LocalDatabase localDatabase;
  final bool refresh;
  bool _popEd = false;

  Future<FetchedProduct> openBestChoice() async {
    final Product? product = await DaoProduct(localDatabase).get(barcode);
    if (product != null) {
      return FetchedProduct(product);
    }
    return openUniqueProductSearch();
  }

  Future<FetchedProduct> openUniqueProductSearch() async {
    final FetchedProduct? result = await showDialog<FetchedProduct>(
      context: context,
      builder: (BuildContext context) {
        BarcodeProductQuery(
          barcode: barcode,
          languageCode: ProductQuery.getCurrentLanguageCode(context),
          countryCode: ProductQuery.getCurrentCountryCode(),
          daoProduct: DaoProduct(localDatabase),
        ).getFetchedProduct().then<void>(
              (final FetchedProduct value) => _popSearchingDialog(value),
            );
        return _getSearchingDialog();
      },
    );
    return result ?? FetchedProduct.error(FetchedProductStatus.userCancelled);
  }

  void _popSearchingDialog(final FetchedProduct fetchedProduct) {
    if (_popEd) {
      return;
    }
    _popEd = true;
    Navigator.of(context, rootNavigator: true).pop(fetchedProduct);
  }

  Widget _getSearchingDialog() => SmoothAlertDialog(
        close: false,
        body: ListTile(
          leading: const CircularProgressIndicator(),
          title: Text(
            refresh
                ? AppLocalizations.of(context)!.refreshing_product
                : '${AppLocalizations.of(context)!.looking_for}: $barcode',
          ),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context)!.stop,
            onPressed: () => _popSearchingDialog(
              FetchedProduct.error(FetchedProductStatus.userCancelled),
            ),
          ),
        ],
      );

  void _openProductNotFoundDialog() => showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          return SmoothAlertDialog(
            close: false,
            body: Text(
              refresh
                  ? AppLocalizations.of(context)!.could_not_refresh
                  : '${AppLocalizations.of(context)!.no_product_found}: $barcode',
            ),
            actions: <SmoothSimpleButton>[
              SmoothSimpleButton(
                text: AppLocalizations.of(context)!.close,
                onPressed: () => Navigator.pop(context),
              ),
              SmoothSimpleButton(
                text: AppLocalizations.of(context)!.contribute,

                onPressed: () => Navigator.pop(
                    context), // TODO(monsieurtanuki): to be implemented
              ),
            ],
          );
        },
      );

  static Widget getErrorMessage(final String message) => ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: Text(message),
      );

  void _openErrorMessage(final String message) => showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          close: false,
          body: getErrorMessage(message),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              text: AppLocalizations.of(context)!.close,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

  /// Opens an error dialog; to be used only if the status is not ok.
  void openError(final FetchedProduct fetchedProduct) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    switch (fetchedProduct.status) {
      case FetchedProductStatus.ok:
        throw Exception("You're not supposed to call this if the status is ok");
      case FetchedProductStatus.userCancelled:
        _openErrorMessage(appLocalizations.product_internet_cancel);
        return;
      case FetchedProductStatus.internetError:
        _openErrorMessage(appLocalizations.product_internet_error);
        return;
      case FetchedProductStatus.internetNotFound:
        _openProductNotFoundDialog();
        return;
    }
  }
}
