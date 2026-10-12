import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_square/knowledge_panel_square_item.dart';

class KnowledgePanelSquareCard extends StatelessWidget {
  const KnowledgePanelSquareCard({
    required this.panels,
    required this.panelsIds,
    required this.product,
    super.key,
  });

  final List<KnowledgePanel> panels;
  final List<String>? panelsIds;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final int rowCount = (panels.length + 1) ~/ 2;

    return Column(
      children: List<Widget>.generate(rowCount, (int index) {
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
                    panelId: panelsIds?[firstIndex],
                  ),
                  const VerticalDivider(thickness: 1.0),
                  if (secondIndex < panels.length)
                    KnowledgePanelSquareItem(
                      panel: panels[secondIndex],
                      panelId: panelsIds?[secondIndex],
                    )
                  else
                    const Spacer(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
