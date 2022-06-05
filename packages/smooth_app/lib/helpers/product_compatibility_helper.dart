import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/personalized_search/matched_product_v2.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class ProductCompatibilityHelper {
  ProductCompatibilityHelper.product(final MatchedProductV2 product)
      : status = product.status;

  const ProductCompatibilityHelper.status(this.status);

  final MatchedProductStatusV2 status;

  Color getHeaderBackgroundColor(bool darkMode) {
    if (darkMode) {
      return _getDarkColors();
    } else {
      return _getLightColors();
    }
  }

  Color getButtonColor(bool darkMode) {
    if (darkMode) {
      return _getLightColors();
    } else {
      return _getDarkColors();
    }
  }

  Color getHeaderForegroundColor(bool darkMode) =>
      darkMode ? Colors.white : Colors.black;

  Color getButtonForegroundColor(bool darkMode) =>
      getHeaderForegroundColor(darkMode);

  // According to color contrast tool https://material.io/resources/color
  // on all those background colors the best is to write in black.
  Color _getDarkColors() {
    switch (status) {
      case MatchedProductStatusV2.VERY_GOOD_MATCH:
        return DARK_GREEN_COLOR;
      case MatchedProductStatusV2.GOOD_MATCH:
        return LIGHT_GREEN_COLOR;
      case MatchedProductStatusV2.POOR_MATCH:
        return DARK_YELLOW_COLOR;
      case MatchedProductStatusV2.MAY_NOT_MATCH:
        return DARK_ORANGE_COLOR;
      case MatchedProductStatusV2.DOES_NOT_MATCH:
        return RED_COLOR;
      case MatchedProductStatusV2.UNKNOWN_MATCH:
        return FAIR_GREY_COLOR;
    }
  }

  Color _getLightColors() {
    // TODO(monsieurtanuki): difference between dark and light
    return _getDarkColors();
  }

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
