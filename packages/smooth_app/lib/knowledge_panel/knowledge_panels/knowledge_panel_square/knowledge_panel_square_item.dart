import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_evaluation_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_indicator.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class KnowledgePanelSquareItem extends StatelessWidget {
  const KnowledgePanelSquareItem({required this.panel, required this.theme});

  final KnowledgePanel panel;
  final SmoothColorsThemeExtension theme;

  @override
  Widget build(BuildContext context) {
    final String title =
        panel.titleElement?.valueString ??
        panel.titleElement?.value?.toString() ??
        '';

    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: VERY_LARGE_SPACE,
          vertical: MEDIUM_SPACE,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              spacing: SMALL_SPACE,
              children: <Widget>[
                Flexible(
                  child: Text(
                    panel.titleElement?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                icons.Chevron.horizontalDirectional(
                  context,
                  size: 12.0,
                  color: theme.greyDark,
                ),
              ],
            ),
            const SizedBox(height: SMALL_SPACE),
            Expanded(
              child: Row(
                spacing: MEDIUM_SPACE,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  KnowledgePanelIndicator(
                    evaluation: panel.evaluation,
                    themeExtension: theme,
                  ),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: panel.evaluation.indicatorColor(theme),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
