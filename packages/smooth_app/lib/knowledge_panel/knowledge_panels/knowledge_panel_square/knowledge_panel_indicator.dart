import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_evaluation_extension.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class KnowledgePanelIndicator extends StatelessWidget {
  const KnowledgePanelIndicator({
    required this.evaluation,
    required this.themeExtension,
    super.key,
  });

  final Evaluation? evaluation;
  final SmoothColorsThemeExtension themeExtension;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 20.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: evaluation.indicatorColor(themeExtension),
        ),
      ),
    );
  }
}
