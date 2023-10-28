import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
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
        KnowledgePanelsBuilder.getKnowledgePanel(product, panelId)!;
    final List<Widget> elementWidgets = <Widget>[];
    final Widget? summary = KnowledgePanelsBuilder.getPanelSummaryWidget(
      panel,
      isClickable: false,
    );
    if (summary != null) {
      elementWidgets.add(summary);
    }
    if (panel.elements != null) {
      for (final KnowledgePanelElement element in panel.elements!) {
        final Widget? elementWidget = KnowledgePanelsBuilder.getElementWidget(
          knowledgePanelElement: element,
          product: product,
          isInitiallyExpanded: isInitiallyExpanded,
        );
        if (elementWidget != null) {
          elementWidgets.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(top: VERY_SMALL_SPACE),
              child: elementWidget,
            ),
          );
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: elementWidgets,
    );
  }
}
