import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class ScanProductCardNotFound extends StatelessWidget {
  ScanProductCardNotFound({
    required this.barcode,
    this.onAddProduct,
    this.onRemoveProduct,
  }) : assert(barcode.isNotEmpty);

  final String barcode;
  final Future<void> Function()? onAddProduct;
  final OnRemoveCallback? onRemoveProduct;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();
    final bool dense = context.read<ScanCardDensity>() == ScanCardDensity.DENSE;

    return ScanProductBaseCard(
      headerLabel: appLocalizations.carousel_unknown_product_header,
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
            title: appLocalizations.carousel_unknown_product_title,
            padding: EdgeInsetsDirectional.only(
              top: dense ? 0.0 : 5.0,
              end: 25.0,
            ),
          ),
          SizedBox(height: dense ? BALANCED_SPACE : LARGE_SPACE),
          ScanProductBaseCardText(
            text: TextWithBubbleParts(
              text: appLocalizations.carousel_unknown_product_text,
              backgroundColor: theme.primarySemiDark,
              textStyle: const TextStyle(
                fontSize: 14.5,
              ),
              bubbleTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              bubblePadding: const EdgeInsetsDirectional.only(
                top: 2.5,
                bottom: 3.5,
                start: 10.0,
                end: 10.0,
              ),
            ),
          ),
          ScanProductBaseCardBarcode(
            barcode: barcode,
            height: 75.0,
            padding: const EdgeInsetsDirectional.only(top: MEDIUM_SPACE),
          ),
          const Spacer(),
          ScanProductBaseCardButton(
            text: appLocalizations.carousel_unknown_product_button,
            onTap: () async {
              await AppNavigator.of(context).push(
                AppRoutes.PRODUCT_CREATOR(barcode),
              );
              await onAddProduct?.call();
            },
          ),
        ],
      ),
    );
  }
}
