import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_summary_card.dart';

class KnowledgePanelCard extends StatelessWidget {
  const KnowledgePanelCard({
    required this.panel,
    required this.allPanels,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;

  @override
  Widget build(BuildContext context) {
    // If [expanded] = true, render all panel elements (including summary), otherwise just renders panel summary.
    if (panel.expanded ?? false) {
      return KnowledgePanelExpandedCard(
        panel: panel,
        allPanels: allPanels,
      );
    }
    return InkWell(
      child: KnowledgePanelSummaryCard(
        panel,
        allowClicking: true,
      ),
      onTap: () {
        Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => KnowledgePanelPage(
              panel: panel,
              allPanels: allPanels,
            ),
          ),
        );
      },
    );
  }
}
