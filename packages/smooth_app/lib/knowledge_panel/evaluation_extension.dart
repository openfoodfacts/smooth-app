import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Extension on Evaluation.
extension EvaluationExtension on Evaluation? {
  Color? getColor(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    return switch (this) {
      Evaluation.BAD => theme.error,
      Evaluation.GOOD => theme.success,
      Evaluation.AVERAGE => theme.warning,
      _ => null,
    };
  }

  IconData? getIconData() => switch (this) {
    Evaluation.BAD => Icons.sentiment_very_dissatisfied,
    Evaluation.AVERAGE => Icons.sentiment_satisfied,
    Evaluation.GOOD => Icons.sentiment_very_satisfied,
    _ => null,
  };

  bool isValid() => switch (this) {
    Evaluation.BAD => true,
    Evaluation.AVERAGE => true,
    Evaluation.GOOD => true,
    _ => false,
  };
}
