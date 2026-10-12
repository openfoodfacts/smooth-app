import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

extension EvaluationExtension on Evaluation? {
  Color indicatorColor(SmoothColorsThemeExtension theme) {
    return switch (this) {
      Evaluation.GOOD => theme.success,
      Evaluation.BAD => theme.error,
      Evaluation.AVERAGE => theme.warning,
      _ => theme.greyNormal,
    };
  }
}
