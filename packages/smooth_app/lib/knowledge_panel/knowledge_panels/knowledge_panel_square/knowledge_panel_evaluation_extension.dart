import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

extension EvaluationExtension on Evaluation? {
  Color indicatorColor(SmoothColorsThemeExtension themeExtension) {
    if (this == null) {
      return Colors.grey;
    }
    switch (this!) {
      case Evaluation.GOOD:
        return themeExtension.success;
      case Evaluation.BAD:
        return themeExtension.error;
      case Evaluation.AVERAGE:
        return themeExtension.warning;
      default:
        return Colors.grey;
    }
  }
}
