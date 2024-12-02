import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_button_with_arrow.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/query/barcode_product_query.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_barcode_widget.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

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

  void _openProductNotFoundDialog() {
    showSmoothModalSheet(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final SmoothColorsThemeExtension theme =
            context.extension<SmoothColorsThemeExtension>();
        final bool lightTheme = context.lightTheme();

        return SmoothModalSheet(
          title: appLocalizations.new_product_found_title,
          prefixIndicator: true,
          bodyPadding: const EdgeInsetsDirectional.only(
            start: VERY_LARGE_SPACE,
            end: VERY_LARGE_SPACE,
            top: LARGE_SPACE,
          ),
          body: Stack(
            children: <Widget>[
              PositionedDirectional(
                bottom: 0.0,
                start: 5.0,
                child: Transform.scale(
                  scale: -1.1,
                  child: const OrangeErrorAnimation(
                    sizeMultiplier: 1.2,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextWithBubbleParts(
                    text: appLocalizations.new_product_found_text,
                    backgroundColor: theme.primarySemiDark,
                    textStyle: const TextStyle(
                      fontSize: 15.5,
                    ),
                    bubbleTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                    bubblePadding: const EdgeInsetsDirectional.only(
                      top: 2.5,
                      bottom: 3.5,
                      start: 10.0,
                      end: 10.0,
                    ),
                  ),
                  const SizedBox(height: LARGE_SPACE),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: ANGULAR_BORDER_RADIUS,
                      color:
                          lightTheme ? theme.primaryMedium : theme.primaryLight,
                    ),
                    child: SmoothBarcodeWidget(
                      barcode: barcode,
                      height: 75.0,
                      padding: const EdgeInsetsDirectional.only(
                        top: MEDIUM_SPACE,
                        start: VERY_LARGE_SPACE,
                        end: VERY_LARGE_SPACE,
                        bottom: MEDIUM_SPACE,
                      ),
                      color: Colors.black,
                      backgroundColor:
                          lightTheme ? Colors.white : Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: MEDIUM_SPACE * 2),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: SmoothButtonWithArrow(
                      text: appLocalizations.new_product_found_button,
                      onTap: () async {
                        await AppNavigator.of(context).push(
                          AppRoutes.PRODUCT_CREATOR(barcode),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height:
                        MediaQuery.of(context).viewPadding.bottom + SMALL_SPACE,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    SmoothHapticFeedback.tadam();
  }

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
