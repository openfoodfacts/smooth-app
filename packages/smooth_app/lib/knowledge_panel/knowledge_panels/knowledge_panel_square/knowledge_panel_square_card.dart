import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_square_item.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class KnowledgePanelSquareCard extends StatelessWidget {
  const KnowledgePanelSquareCard({required this.panels, required this.product});

  final List<KnowledgePanel> panels;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final int rowCount = (panels.length + 1) ~/ 2;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rowCount,
      padding: EdgeInsetsDirectional.zero,
      itemBuilder: (BuildContext context, int index) {
        final int firstIndex = index * 2;
        final int secondIndex = firstIndex + 1;
        return Column(
          children: <Widget>[
            if (index > 0) const Divider(thickness: 1.0),
            IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  KnowledgePanelSquareItem(
                    panel: panels[firstIndex],
                    theme: theme,
                  ),
                  const VerticalDivider(thickness: 1.0),
                  if (secondIndex < panels.length)
                    KnowledgePanelSquareItem(
                      panel: panels[secondIndex],
                      theme: theme,
                    )
                  else
                    const Spacer(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
