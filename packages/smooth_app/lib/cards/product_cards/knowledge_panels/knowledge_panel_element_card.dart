import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_table_card.dart';

class KnowledgePanelElementCard extends StatelessWidget {
  const KnowledgePanelElementCard({
    required this.knowledgePanelElement,
    required this.allPanels,
  });

  final KnowledgePanelElement knowledgePanelElement;
  final KnowledgePanels allPanels;

  @override
  Widget build(BuildContext context) {
    switch (knowledgePanelElement.elementType) {
      case KnowledgePanelElementType.TEXT:
        return HtmlWidget(knowledgePanelElement.textElement!.html);
      case KnowledgePanelElementType.IMAGE:
        return Image.network(
          knowledgePanelElement.imageElement!.url,
          width: knowledgePanelElement.imageElement!.width!.toDouble(),
          height: knowledgePanelElement.imageElement!.height!.toDouble(),
        );
      case KnowledgePanelElementType.PANEL:
        return KnowledgePanelCard(
          panel: allPanels
              .panelIdToPanelMap[knowledgePanelElement.panelElement!.panelId]!,
          allPanels: allPanels,
        );
      case KnowledgePanelElementType.PANEL_GROUP:
        return KnowledgePanelGroupCard(
            groupElement: knowledgePanelElement.panelGroupElement!,
            allPanels: allPanels);
      case KnowledgePanelElementType.TABLE:
        return KnowledgePanelTableCard(
          tableElement: knowledgePanelElement.tableElement!,
        );
      case KnowledgePanelElementType.UNKNOWN:
        throw UnsupportedError(
            'ElementType not supported yet: ${knowledgePanelElement.elementType}');
    }
  }
}
