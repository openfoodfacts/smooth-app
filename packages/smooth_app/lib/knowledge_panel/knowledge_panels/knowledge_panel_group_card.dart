import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';

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
    return Provider<KnowledgePanelPanelGroupElement>(
      lazy: true,
      create: (_) => groupElement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (groupElement.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: LARGE_SPACE),
              child: Text(
                groupElement.title,
                style: themeData.textTheme.subtitle2!.apply(color: Colors.grey),
              ),
            ),
          for (String panelId in groupElement.panelIds)
            KnowledgePanelCard(
              panel: allPanels.panelIdToPanelMap[panelId]!,
              allPanels: allPanels,
            )
        ],
      ),
    );
  }

  static KnowledgePanelPanelGroupElement? groupElementOf(BuildContext context) {
    try {
      return Provider.of<KnowledgePanelPanelGroupElement>(context);
    } catch (_) {
      return null;
    }
  }
}
