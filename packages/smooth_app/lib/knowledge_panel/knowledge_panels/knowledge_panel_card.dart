import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_summary_card.dart';

class KnowledgePanelCard extends StatelessWidget {
  const KnowledgePanelCard({
    required this.panel,
    required this.allPanels,
    required this.product,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;
  final Product product;

  @override
  Widget build(BuildContext context) {
    // If [expanded] = true, render all panel elements (including summary), otherwise just renders panel summary.
    if (panel.expanded ?? false) {
      return KnowledgePanelExpandedCard(
        panel: panel,
        allPanels: allPanels,
        product: product,
      );
    }

    final KnowledgePanelPanelGroupElement? group =
        KnowledgePanelGroupCard.groupElementOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: InkWell(
        borderRadius: ANGULAR_BORDER_RADIUS,
        child: KnowledgePanelSummaryCard(
          panel,
          isClickable: true,
          margin: EdgeInsets.zero,
        ),
        onTap: () {
          Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => KnowledgePanelPage(
                groupElement: group,
                panel: panel,
                allPanels: allPanels,
                product: product,
              ),
            ),
          );
        },
      ),
    );
  }
}
