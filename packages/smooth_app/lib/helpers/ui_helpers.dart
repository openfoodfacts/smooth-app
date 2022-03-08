/// Contains UI related constant that are shared across the entire app.
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';

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
