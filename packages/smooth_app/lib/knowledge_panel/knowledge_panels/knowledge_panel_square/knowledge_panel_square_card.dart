import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_evaluation_extension.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_indicator.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class KnowledgePanelSquareCard extends StatelessWidget {
  const KnowledgePanelSquareCard({required this.panels, required this.product});

  final List<KnowledgePanel> panels;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...List<Widget>.generate((panels.length + 1) ~/ 2, (int index) {
          final int firstIndex = index * 2;
          final int secondIndex = firstIndex + 1;
          return Column(
            children: <Widget>[
              if (index > 0) const Divider(thickness: 1.0),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    _buildPanel(context, panels[firstIndex], theme),
                    const VerticalDivider(thickness: 1.0),
                    if (secondIndex < panels.length)
                      _buildPanel(context, panels[secondIndex], theme)
                    else
                      const Spacer(),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPanel(
    BuildContext context,
    KnowledgePanel panel,
    SmoothColorsThemeExtension themeExtension,
  ) {
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
                Icon(
                  ConstantIcons.forwardIcon,
                  color: themeExtension.primaryTone,
                  size: 16.0,
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
                    themeExtension: themeExtension,
                  ),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: panel.evaluation.indicatorColor(themeExtension),
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
