import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_element_card.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

class KnowledgePanelsBuilder {
  const KnowledgePanelsBuilder();

  List<Widget> build(
    KnowledgePanels knowledgePanels, {
    final Product? product,
    final AppLocalizations? appLocalizations,
  }) {
    final List<Widget> rootPanelWidgets = <Widget>[];
    if (knowledgePanels.panelIdToPanelMap['root'] == null) {
      return rootPanelWidgets;
    }
    if (knowledgePanels.panelIdToPanelMap['root']!.elements == null) {
      return rootPanelWidgets;
    }
    for (final KnowledgePanelElement panelElement
        in knowledgePanels.panelIdToPanelMap['root']!.elements!) {
      if (panelElement.elementType != KnowledgePanelElementType.PANEL) {
        continue;
      }
      final String panelId = panelElement.panelElement!.panelId;
      final KnowledgePanel rootPanel =
          knowledgePanels.panelIdToPanelMap[panelId]!;
      // [knowledgePanelElementWidgets] are a set of widgets inside the root panel.
      final List<Widget> knowledgePanelElementWidgets = <Widget>[];
      for (final KnowledgePanelElement knowledgePanelElement
          in rootPanel.elements ?? <KnowledgePanelElement>[]) {
        knowledgePanelElementWidgets.add(KnowledgePanelElementCard(
          knowledgePanelElement: knowledgePanelElement,
          allPanels: knowledgePanels,
        ));
      }
      if (product != null && appLocalizations != null) {
        if (panelId == 'health_card') {
          if (product.statesTags
                  ?.contains('en:nutrition-facts-to-be-completed') ??
              false) {
            knowledgePanelElementWidgets.add(
              dummyAddButton(
                appLocalizations.score_add_missing_nutrition_facts,
              ),
            );
          }
          if (product.statesTags?.contains('en:ingredients-to-be-completed') ??
              false) {
            knowledgePanelElementWidgets.add(
              dummyAddButton(
                appLocalizations.score_add_missing_ingredients,
              ),
            );
          }
        }
      }
      rootPanelWidgets.add(Column(children: knowledgePanelElementWidgets));
    }
    return rootPanelWidgets;
  }
}
