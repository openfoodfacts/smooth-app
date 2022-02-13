import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/helpers/smooth_matched_product.dart';

class ProductCompatibilityHelper {
  const ProductCompatibilityHelper(this.matchedProduct);

  final MatchedProduct matchedProduct;

  Color getBackgroundColor() {
    switch (matchedProduct.status) {
      case null:
      case MatchedProductStatus.UNKNOWN:
        return Colors.grey;
      case MatchedProductStatus.NO:
        return Colors.red;
      case MatchedProductStatus.YES:
        return Colors.green;
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
