import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_summary_card.dart';

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
        return KnowledgePanelSummaryCard(allPanels
            .panelIdToPanelMap[knowledgePanelElement.panelElement!.panelId]!);
      case KnowledgePanelElementType.PANEL_GROUP:
        return KnowledgePanelGroupCard(
            groupElement: knowledgePanelElement.panelGroupElement!,
            allPanels: allPanels);
      default:
        throw UnsupportedError(
            'ElementType not supported yet: ${knowledgePanelElement.elementType}');
    }
  }
}
