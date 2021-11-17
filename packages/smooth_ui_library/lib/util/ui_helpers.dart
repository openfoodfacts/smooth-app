/// Contains UI related constant that are shared across the entire app.
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';

const Widget EMPTY_WIDGET = SizedBox.shrink();

const double VERY_SMALL_SPACE = 4.0;
const double SMALL_SPACE = 8.0;
const double MEDIUM_SPACE = 12.0;
const double LARGE_SPACE = 16.0;
const double VERY_LARGE_SPACE = 20.0;

// ignore: avoid_classes_with_only_static_members
/// Creates the Size or flex for widgets that contains icons.
class IconWidgetSizer {
  /// Ratio of Widget size taken up by an icon.
  static const double _ICON_WIDGET_SIZE_RATIO = 1 / 10;

  static double getIconSizeFromContext(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
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
      return Colors.grey;
    case Evaluation.NEUTRAL:
      return Colors.orange;
    case Evaluation.BAD:
      return Colors.red;
    case Evaluation.GOOD:
      return Colors.green;
  }
}
