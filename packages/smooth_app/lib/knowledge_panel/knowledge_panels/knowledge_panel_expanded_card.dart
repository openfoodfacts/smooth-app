import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_summary_card.dart';

class KnowledgePanelExpandedCard extends StatelessWidget {
  const KnowledgePanelExpandedCard({
    required this.panel,
    required this.allPanels,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;

  @override
  Widget build(BuildContext context) {
    final List<Widget> elementWidgets = <Widget>[];
    elementWidgets.add(KnowledgePanelSummaryCard(panel, isClickable: false));
    for (final KnowledgePanelElement element
        in panel.elements ?? <KnowledgePanelElement>[]) {
      elementWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: VERY_SMALL_SPACE),
          child: KnowledgePanelElementCard(
            knowledgePanelElement: element,
            allPanels: allPanels,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: elementWidgets,
    );
  }
}
