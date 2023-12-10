import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// a11y helper for Evaluation.
extension EvaluationExtension on Evaluation? {
  /// Returns the color in light/day mode.
  Color getColor(final Brightness brightness) =>
      brightness == Brightness.light ? getLightModeColor() : getDarkModeColor();

  /// Returns the color in light/day mode.
  Color getLightModeColor() => switch (this) {
        Evaluation.BAD => RED_COLOR,
        Evaluation.AVERAGE => LIGHT_ORANGE_COLOR,
        Evaluation.GOOD => LIGHT_GREEN_COLOR,
        _ => PRIMARY_GREY_COLOR,
      };

  /// Returns the color in dark/night mode.
  Color getDarkModeColor() => switch (this) {
        Evaluation.BAD => RED_COLOR,
        Evaluation.AVERAGE => LIGHT_ORANGE_COLOR,
        Evaluation.GOOD => LIGHT_GREEN_COLOR,
        _ => LIGHT_GREY_COLOR,
      };

  /// Returns an "a11y" icon.
  IconData? getA11YIconData() => switch (this) {
        Evaluation.BAD => Icons.sentiment_very_dissatisfied_sharp,
        Evaluation.AVERAGE => Icons.sentiment_neutral_rounded,
        Evaluation.GOOD => Icons.sentiment_very_satisfied_sharp,
        _ => null,
      };
}
