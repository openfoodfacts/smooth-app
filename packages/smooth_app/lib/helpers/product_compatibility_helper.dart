import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/smooth_matched_product.dart';

class ProductCompatibilityHelper {
  const ProductCompatibilityHelper(this.matchedProduct);

  final MatchedProduct matchedProduct;

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
      darkMode ? Colors.white : Colors.black;

  Color _getDarkColors() {
    switch (matchedProduct.status) {
      case null:
      case MatchedProductStatus.UNKNOWN:
        return PRIMARY_GREY_COLOR;
      case MatchedProductStatus.NO:
        return DARK_RED_COLOR;
      case MatchedProductStatus.YES:
        return DARK_GREEN_COLOR;
    }
  }

  Color _getLightColors() {
    switch (matchedProduct.status) {
      case null:
      case MatchedProductStatus.UNKNOWN:
        return LIGHT_GREY_COLOR;
      case MatchedProductStatus.NO:
        return LIGHT_RED_COLOR;
      case MatchedProductStatus.YES:
        return LIGHT_GREEN_COLOR;
    }
  }

  String getHeaderText(final AppLocalizations appLocalizations) {
    switch (matchedProduct.status) {
      case null:
      case MatchedProductStatus.UNKNOWN:
        return appLocalizations.product_compatibility_unknown;
      case MatchedProductStatus.NO:
        return appLocalizations.product_compatibility_incompatible;
      case MatchedProductStatus.YES:
        return appLocalizations.product_compatibility_good;
    }
  }

  String getSubtitle(final AppLocalizations appLocalizations) {
    switch (matchedProduct.status) {
      case null:
      case MatchedProductStatus.UNKNOWN:
        return appLocalizations.unknown;
      case MatchedProductStatus.NO:
        return appLocalizations.incompatible;
      case MatchedProductStatus.YES:
        return appLocalizations.compatible;
    }
  }
}
