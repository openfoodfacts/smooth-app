import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/pages/product/add_new_product_page.dart';
import 'package:smooth_app/query/barcode_product_query.dart';

/// Dialog helper for product barcode search
class ProductDialogHelper {
  ProductDialogHelper({
    required this.barcode,
    required this.context,
    required this.localDatabase,
  });

  static const String unknownSvgNutriscore =
      'https://static.openfoodfacts.org/images/attributes/nutriscore-unknown.svg';
  static const String unknownSvgEcoscore =
      'https://static.openfoodfacts.org/images/attributes/ecoscore-unknown.svg';

  final String barcode;
  final BuildContext context;
  final LocalDatabase localDatabase;

  Future<FetchedProduct> openBestChoice() async {
    final Product? product = await DaoProduct(localDatabase).get(barcode);
    if (product != null) {
      return FetchedProduct(product);
    }
    return openUniqueProductSearch();
  }

  Future<FetchedProduct> openUniqueProductSearch() async =>
      await LoadingDialog.run<FetchedProduct>(
          context: context,
          future: BarcodeProductQuery(
            barcode: barcode,
            daoProduct: DaoProduct(localDatabase),
            isScanned: false,
          ).getFetchedProduct(),
          title: '${AppLocalizations.of(context).looking_for}: $barcode') ??
      FetchedProduct.error(FetchedProductStatus.userCancelled);

  void _openProductNotFoundDialog() => showDialog<Widget>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body: LayoutBuilder(
            builder: (
              final BuildContext context,
              final BoxConstraints constraints,
            ) {
              final AppLocalizations appLocalizations =
                  AppLocalizations.of(context);
              const double svgPadding = SMALL_SPACE;
              final double svgWidth = (constraints.maxWidth - svgPadding) / 2;
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/onboarding/birthday-cake.svg',
                    package: AppHelper.APP_PACKAGE,
                    height: MINIMUM_TOUCH_SIZE * 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: SMALL_SPACE),
                    child: Text(
                      appLocalizations.new_product_dialog_title,
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    appLocalizations.barcode_barcode(barcode),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                    child: Row(
                      children: <Widget>[
                        SvgCache(
                          unknownSvgNutriscore,
                          width: svgWidth,
                        ),
                        const SizedBox(width: svgPadding),
                        SvgCache(
                          unknownSvgEcoscore,
                          width: svgWidth,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: SMALL_SPACE),
                    child: Text(
                      appLocalizations.new_product_dialog_description,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
          positiveAction: SmoothActionButton(
            text: AppLocalizations.of(context).contribute,
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => AddNewProductPage(barcode),
              ),
            ),
          ),
          negativeAction: SmoothActionButton(
            text: AppLocalizations.of(context).close,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );

  static Widget getErrorMessage(final String message) => Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: SMALL_SPACE),
          Expanded(child: Text(message))
        ],
      );

  void _openErrorMessage(final String message) => showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body: getErrorMessage(message),
          positiveAction: SmoothActionButton(
            text: AppLocalizations.of(context).close,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );

  /// Opens an error dialog; to be used only if the status is not ok.
  void openError(final FetchedProduct fetchedProduct) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    switch (fetchedProduct.status) {
      case FetchedProductStatus.ok:
        throw Exception("You're not supposed to call this if the status is ok");
      case FetchedProductStatus.userCancelled:
        return;
      case FetchedProductStatus.internetError:
        _openErrorMessage(appLocalizations.product_internet_error);
        return;
      case FetchedProductStatus.internetNotFound:
        _openProductNotFoundDialog();
        return;
      case FetchedProductStatus.codeInvalid:
        _openErrorMessage(appLocalizations.barcode_invalid_error);
        return;
    }
  }
}
