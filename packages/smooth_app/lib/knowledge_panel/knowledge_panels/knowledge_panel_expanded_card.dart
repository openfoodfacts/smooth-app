import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_summary_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';

class KnowledgePanelExpandedCard extends StatelessWidget {
  const KnowledgePanelExpandedCard({
    required this.panelId,
    required this.product,
    required this.isInitiallyExpanded,
  });

  final Product product;
  final String panelId;
  final bool isInitiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final KnowledgePanel panel =
        KnowledgePanelWidget.getKnowledgePanel(product, panelId)!;
    final List<Widget> elementWidgets = <Widget>[];
    elementWidgets.add(KnowledgePanelSummaryCard(panel, isClickable: false));
    for (final KnowledgePanelElement element
        in panel.elements ?? <KnowledgePanelElement>[]) {
      elementWidgets.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(top: VERY_SMALL_SPACE),
          child: KnowledgePanelElementCard(
            knowledgePanelElement: element,
            product: product,
            isInitiallyExpanded: isInitiallyExpanded,
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
