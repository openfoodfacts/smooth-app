import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_product_cards.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';

/// Knowledge Panel Cards as provided by the server.
class StandardKnowledgePanelCards extends StatelessWidget {
  const StandardKnowledgePanelCards(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final List<Widget> knowledgePanelWidgets = <Widget>[];
    if (product.knowledgePanels != null) {
      final List<KnowledgePanelElement> elements =
          KnowledgePanelsBuilder.getRootPanelElements(product);
      for (final KnowledgePanelElement panelElement in elements) {
        final List<Widget> children = KnowledgePanelsBuilder.getChildren(
          context,
          panelElement: panelElement,
          product: product,
          onboardingMode: false,
        );
        if (children.isNotEmpty) {
          knowledgePanelWidgets.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        }
      }
    }
    return KnowledgePanelProductCards(knowledgePanelWidgets);
  }
}
