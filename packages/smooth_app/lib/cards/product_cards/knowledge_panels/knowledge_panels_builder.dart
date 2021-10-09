import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/database/knowledge_panels_query.dart';

class KnowledgePanelsBuilder {
  const KnowledgePanelsBuilder();

  List<Widget> _build(KnowledgePanels knowledgePanels) {
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
          in rootKnowledgePanel.elements) {
        knowledgePanelElementWidgets.add(KnowledgePanelElementCard(
          knowledgePanelElement: knowledgePanelElement,
          allPanels: knowledgePanels,
        ));
      }
      rootPanelWidgets.add(Column(children: knowledgePanelElementWidgets));
    }
    return rootPanelWidgets;
  }

  // Build KnowledgePanels from Async query to fetch KnowledgePanels
  List<Widget> buildKnowledgePanelWidgets(
      BuildContext context, AsyncSnapshot<KnowledgePanels> snapshot) {
    if (snapshot.hasData) {
      // Render all KnowledgePanels
      return _build(snapshot.data!);
    } else if (snapshot.hasError) {
      // TODO(jasmeet): Retry the request.
      // Do nothing for now.
      return <Widget>[];
    } else {
      // Query results not available yet.
      return <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ],
          ),
        ),
      ];
    }
  }
}
