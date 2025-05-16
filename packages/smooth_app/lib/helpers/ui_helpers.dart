import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Contains UI related constant that are shared across the entire app.

/// Main attributes, to be displayed on top
const List<String> SCORE_ATTRIBUTE_IDS = <String>[
  Attribute.ATTRIBUTE_NUTRISCORE,
  Attribute.ATTRIBUTE_ECOSCORE,
];

// ignore: avoid_classes_with_only_static_members
/// Creates the Size or flex for widgets that contains icons.
class IconWidgetSizer {
  /// Ratio of Widget size taken up by an icon.
  static const double _ICON_WIDGET_SIZE_RATIO = 1 / 10;

  static double getIconSizeFromContext(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    return screenSize.width * _ICON_WIDGET_SIZE_RATIO;
  }

  static int getIconFlex() {
    return (_ICON_WIDGET_SIZE_RATIO * 10).toInt();
  }

  static int getRemainingWidgetFlex() {
    return (10 - _ICON_WIDGET_SIZE_RATIO * 10).toInt();
  }
}

Color? getTextColorFromKnowledgePanelElementEvaluation(Evaluation evaluation) {
  switch (evaluation) {
    case Evaluation.UNKNOWN:
      // Use default color for unknown.
      return null;
    case Evaluation.AVERAGE:
      return GREY_COLOR;
    case Evaluation.NEUTRAL:
      return DARK_ORANGE_COLOR;
    case Evaluation.BAD:
      return RED_COLOR;
    case Evaluation.GOOD:
      return DARK_GREEN_COLOR;
  }
}

extension BoxConstraintsExtension on BoxConstraints {
  double get minSide => math.min(maxWidth, maxHeight);
}

extension StatelessWidgetExtension on StatelessWidget {
  void onNextFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}

extension StateExtension<T extends StatefulWidget> on State<T> {
  void onNextFrame(VoidCallback callback, {bool forceRedraw = false}) {
    final WidgetsBinding binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      callback();
    });

    if (forceRedraw) {
      binding.ensureVisualUpdate();
    }
  }
}

extension ScrollMetricsExtension on ScrollMetrics {
  double get page => extentBefore / extentInside;

  bool get hasScrolled => extentBefore % extentInside != 0;
}

extension ScrollControllerExtension on ScrollController {
  void jumpBy(double offset) => jumpTo(position.pixels + offset);

  void animateBy(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) =>
      animateTo(
        position.pixels + offset,
        duration: duration,
        curve: curve,
      );
}
