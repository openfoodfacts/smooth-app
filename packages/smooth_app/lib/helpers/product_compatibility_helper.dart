import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class ProductCompatibilityHelper {
  ProductCompatibilityHelper.product(final MatchedProductV2 product)
      : status = product.status;

  const ProductCompatibilityHelper.status(this.status);

  final MatchedProductStatusV2 status;

  Color getColor(BuildContext context) {
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return switch (status) {
      MatchedProductStatusV2.VERY_GOOD_MATCH => theme.green,
      MatchedProductStatusV2.GOOD_MATCH => theme.green,
      MatchedProductStatusV2.POOR_MATCH => theme.orange,
      MatchedProductStatusV2.MAY_NOT_MATCH => theme.orange,
      MatchedProductStatusV2.DOES_NOT_MATCH => theme.red,
      MatchedProductStatusV2.UNKNOWN_MATCH => theme.greyNormal,
    };
  }

  Color getHeaderForegroundColor(bool darkMode) =>
      darkMode ? Colors.white : Colors.black;

  Color getButtonForegroundColor(bool darkMode) =>
      getHeaderForegroundColor(darkMode);

  String getHeaderText(final AppLocalizations appLocalizations) {
    switch (status) {
      case MatchedProductStatusV2.VERY_GOOD_MATCH:
        return appLocalizations.match_very_good;
      case MatchedProductStatusV2.GOOD_MATCH:
        return appLocalizations.match_good;
      case MatchedProductStatusV2.POOR_MATCH:
        return appLocalizations.match_poor;
      case MatchedProductStatusV2.MAY_NOT_MATCH:
        return appLocalizations.match_may_not;
      case MatchedProductStatusV2.DOES_NOT_MATCH:
        return appLocalizations.match_does_not;
      case MatchedProductStatusV2.UNKNOWN_MATCH:
        return appLocalizations.match_unknown;
    }
  }

  String getSubtitle(final AppLocalizations appLocalizations) {
    switch (status) {
      case MatchedProductStatusV2.VERY_GOOD_MATCH:
        return appLocalizations.match_short_very_good;
      case MatchedProductStatusV2.GOOD_MATCH:
        return appLocalizations.match_short_good;
      case MatchedProductStatusV2.POOR_MATCH:
        return appLocalizations.match_short_poor;
      case MatchedProductStatusV2.MAY_NOT_MATCH:
        return appLocalizations.match_short_may_not;
      case MatchedProductStatusV2.DOES_NOT_MATCH:
        return appLocalizations.match_short_does_not;
      case MatchedProductStatusV2.UNKNOWN_MATCH:
        return appLocalizations.match_short_unknown;
    }
  }
}
