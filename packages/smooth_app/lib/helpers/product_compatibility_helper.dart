import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class ProductCompatibilityHelper {
  ProductCompatibilityHelper.product(final MatchedProductV2 product)
    : status = product.status,
      _score = product.score;

  const ProductCompatibilityHelper.status(this.status) : _score = null;

  final double? _score;
  final MatchedProductStatusV2 status;

  Color getColor(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return switch (status) {
      MatchedProductStatusV2.VERY_GOOD_MATCH => theme.success,
      MatchedProductStatusV2.GOOD_MATCH => theme.success,
      MatchedProductStatusV2.POOR_MATCH => theme.warning,
      MatchedProductStatusV2.MAY_NOT_MATCH => theme.warning,
      MatchedProductStatusV2.DOES_NOT_MATCH => theme.error,
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

  String? getFormattedScore({bool singleDigitAllowed = false}) {
    if (_score == null || status == MatchedProductStatusV2.UNKNOWN_MATCH) {
      return null;
    } else if (_score == 0 || (singleDigitAllowed && _score < 10)) {
      return _score.toStringAsFixed(0);
    }

    return NumberFormat('00').format(_score.toInt());
  }
}
