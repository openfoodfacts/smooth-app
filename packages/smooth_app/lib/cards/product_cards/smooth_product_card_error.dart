import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
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

    return ScanProductBaseCard(
      headerLabel: appLocalizations.carousel_error_header,
      headerIndicatorColor: theme.error,
      onRemove: onRemoveProduct,
      backgroundChild: PositionedDirectional(
        top: 0.0,
        end: 5.0,
        child: SvgPicture.asset('assets/product/scan_card_product_error.svg'),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ScanProductBaseCardTitle(
            title: appLocalizations.carousel_error_title,
            padding: const EdgeInsetsDirectional.only(top: 5.0, end: 25.0),
          ),
          const SizedBox(height: LARGE_SPACE),
          ScanProductBaseCardText(
            text: Text(appLocalizations.carousel_error_text_1),
          ),
          ScanProductBaseCardBarcode(
            barcode: barcode,
            height: 75.0,
          ),
          const Spacer(),
          ScanProductBaseCardText(
            text: Text(appLocalizations.carousel_error_text_2),
          ),
          const SizedBox(height: LARGE_SPACE),
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
