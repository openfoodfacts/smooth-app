import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class ScanProductCardNotSupported extends StatelessWidget {
  const ScanProductCardNotSupported({
    required this.barcode,
    required this.onRemoveProduct,
  });

  final String barcode;
  final OnRemoveCallback onRemoveProduct;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();

    return ScanProductBaseCard(
      headerLabel: appLocalizations.carousel_unsupported_header,
      headerIndicatorColor: theme.error,
      onRemove: onRemoveProduct,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ScanProductBaseCardTitle(
            title: appLocalizations.carousel_unsupported_title,
          ),
          ScanProductBaseCardText(
            text: Text(appLocalizations.carousel_unsupported_text),
          ),
          ScanProductBaseCardBarcode(barcode: barcode),
        ],
      ),
    );
  }
}
