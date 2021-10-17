import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_element_card.dart';

class KnowledgePanelsBuilder {
  const KnowledgePanelsBuilder();

  List<Widget> build(KnowledgePanels knowledgePanels) {
    final List<KnowledgePanel> rootKnowledgePanels = <KnowledgePanel>[];
    for (final KnowledgePanel knowledgePanel
        in knowledgePanels.panelIdToPanelMap.values) {
      if (knowledgePanel.parentPanelId == 'root') {
        rootKnowledgePanels.add(knowledgePanel);
      }
    }

    final List<Widget> rootPanelWidgets = <Widget>[];
    for (final KnowledgePanel rootKnowledgePanel in rootKnowledgePanels) {
      // [knowledgePanelElementWidgets] are a set of widgets inside the root panel.
      final List<Widget> knowledgePanelElementWidgets = <Widget>[];
      for (final KnowledgePanelElement knowledgePanelElement
          in rootKnowledgePanel.elements ?? <KnowledgePanelElement>[]) {
        knowledgePanelElementWidgets.add(KnowledgePanelElementCard(
          knowledgePanelElement: knowledgePanelElement,
          allPanels: knowledgePanels,
        ));
      }
      rootPanelWidgets.add(Column(children: knowledgePanelElementWidgets));
    }
    return rootPanelWidgets;
  }
}
