import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_summary_card.dart';

class KnowledgePanelGroupCard extends StatelessWidget {
  const KnowledgePanelGroupCard({
    required this.groupElement,
    required this.allPanels,
  });

  final KnowledgePanelPanelGroupElement groupElement;
  final KnowledgePanels allPanels;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            groupElement.title,
            style: themeData.textTheme.subtitle2!.apply(color: Colors.grey),
          ),
          for (String panelId in groupElement.panelIds)
            KnowledgePanelSummaryCard(allPanels.panelIdToPanelMap[panelId]!)
        ],
      ),
    );
  }
}
