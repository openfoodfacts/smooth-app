import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_evaluation_extension.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_circle.dart';

class KnowledgePanelIndicator extends StatelessWidget {
  const KnowledgePanelIndicator({required this.evaluation, super.key});

  final Evaluation? evaluation;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    return SmoothCircle(
      padding: EdgeInsetsDirectional.zero,
      color: evaluation.indicatorColor(themeExtension),
      child: const SizedBox.square(dimension: 25.0),
    );
  }
}
