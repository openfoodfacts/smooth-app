import 'dart:math' as math;

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
import 'package:smooth_app/generic_lib/widgets/smooth_responsive.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/query/barcode_product_query.dart';

/// Dialog helper for product barcode search
class ProductDialogHelper {
  ProductDialogHelper({
    required this.barcode,
    required this.context,
    required this.localDatabase,
  });

  static const String unknownSvgNutriscore =
      'https://static.openfoodfacts.org/images/attributes/dist/nutriscore-unknown.svg';
  static const String unknownSvgEcoscore =
      'https://static.openfoodfacts.org/images/attributes/dist/ecoscore-unknown.svg';
  static const String unknownSvgNova =
      'https://static.openfoodfacts.org/images/attributes/dist/nova-group-unknown.svg';

  final String barcode;
  final BuildContext context;
  final LocalDatabase localDatabase;

  Future<FetchedProduct> openBestChoice() async {
    final Product? product = await DaoProduct(localDatabase).get(barcode);
    if (product != null) {
      return FetchedProduct.found(product);
    }
    if (localDatabase.upToDate.hasPendingChanges(barcode)) {
      return FetchedProduct.found(Product(barcode: barcode));
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
      const FetchedProduct.userCancelled();

  void _openProductNotFoundDialog() => showDialog<Widget>(
      context: context,
      builder: (BuildContext context) {
        final double availableWidth = MediaQuery.sizeOf(context).width -
            SmoothAlertDialog.defaultMargin.horizontal -
            SmoothAlertDialog.defaultContentPadding(context).horizontal;

        /// The nutriscore logo is 240*130
        final double svgHeight = math.min(
          (availableWidth * 0.4) / 240.0 * 130.0,
          175.0,
        );

        final double heightMultiplier = switch (context.deviceType) {
          DeviceType.small => 1,
          DeviceType.smartphone => 2,
          DeviceType.tablet => 2.5,
          DeviceType.large => 4,
        };

        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        return SmoothAlertDialog(
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/onboarding/birthday-cake.svg',
                package: AppHelper.APP_PACKAGE,
                excludeFromSemantics: true,
              ),
              SizedBox(height: SMALL_SPACE * heightMultiplier),
              Text(
                appLocalizations.new_product_dialog_title,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              SizedBox(height: SMALL_SPACE * heightMultiplier),
              Text(
                appLocalizations.barcode_barcode(barcode),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MEDIUM_SPACE * heightMultiplier),
              Semantics(
                label: appLocalizations
                    .new_product_dialog_illustration_description,
                excludeSemantics: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: SvgCache(
                        unknownSvgNutriscore,
                        height: svgHeight,
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 4,
                      child: SvgCache(
                        unknownSvgEcoscore,
                        height: svgHeight,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SMALL_SPACE * heightMultiplier),
              Text(
                appLocalizations.new_product_dialog_description,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ],
          ),
          actionsAxis: Axis.vertical,
          positiveAction: SmoothActionButton(
            text: AppLocalizations.of(context).contribute,
            onPressed: () async {
              await AppNavigator.of(context).push(
                AppRoutes.PRODUCT_CREATOR(barcode),
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          negativeAction: SmoothActionButton(
            text: AppLocalizations.of(context).close,
            onPressed: () => Navigator.pop(context),
          ),
        );
      });

  static Widget getErrorMessage(final String message) => Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: SMALL_SPACE),
          Expanded(child: Text(message))
        ],
      );

  void _openErrorMessage(final String message) => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final AppLocalizations localizations = AppLocalizations.of(context);

          return SmoothAlertDialog(
            title: localizations.product_internet_error_modal_title,
            body: getErrorMessage(message),
            positiveAction: SmoothActionButton(
              text: localizations.close,
              onPressed: () => Navigator.pop(context),
            ),
          );
        },
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
        _openErrorMessage(
          appLocalizations.product_internet_error_modal_message(
              fetchedProduct.exceptionString ?? '-'),
        );
        return;
      case FetchedProductStatus.internetNotFound:
        _openProductNotFoundDialog();
        return;
    }
  }
}
