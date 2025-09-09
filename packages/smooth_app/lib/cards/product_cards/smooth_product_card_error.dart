import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Product Card when an exception is caught

class ScanProductCardError extends StatelessWidget {
  ScanProductCardError({
    required this.barcode,
    required this.errorType,
    this.onRemoveProduct,
  }) : assert(barcode.isNotEmpty);

  final String barcode;
  final ScannedProductState errorType;
  final OnRemoveCallback? onRemoveProduct;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();
    final bool dense = context.read<ScanCardDensity>() == ScanCardDensity.DENSE;

    return ScanProductBaseCard(
      headerLabel: appLocalizations.carousel_error_header,
      headerIndicatorColor: theme.error,
      onRemove: onRemoveProduct,
      backgroundChild: const PositionedDirectional(
        top: 0.0,
        end: 5.0,
        child: OrangeErrorAnimation(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ScanProductBaseCardTitle(
            title: appLocalizations.carousel_error_title,
            padding: EdgeInsetsDirectional.only(
              top: dense ? 0.0 : 5.0,
              end: 25.0,
            ),
          ),
          const SizedBox(height: LARGE_SPACE),
          ScanProductBaseCardText(
            text: Text(appLocalizations.carousel_error_text_1),
          ),
          ScanProductBaseCardBarcode(
            barcode: barcode,
            height: dense ? 60.0 : 75.0,
          ),
          if (dense) const SizedBox(height: SMALL_SPACE) else const Spacer(),
          ScanProductBaseCardText(
            text: Text(appLocalizations.carousel_error_text_2),
          ),
          if (dense) const Spacer() else const SizedBox(height: LARGE_SPACE),
          ScanProductBaseCardButton(
            text: appLocalizations.carousel_error_button,
            onTap: () async {
              final ContinuousScanModel model =
                  context.read<ContinuousScanModel>();

              model.retryBarcodeFetch(barcode);
            },
          ),
        ],
      ),
    );
  }
}
