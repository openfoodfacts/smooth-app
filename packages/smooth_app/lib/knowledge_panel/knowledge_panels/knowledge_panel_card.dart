import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_summary_card.dart';

class KnowledgePanelCard extends StatelessWidget {
  const KnowledgePanelCard({
    required this.panel,
    required this.allPanels,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;
  static const String EXPAND_PANEL_NUTRITION_TABLE_ID = 'nutrition_facts_table';
  static const String EXPAND_PANEL_INGREDIENTS_ID = 'ingredients';
  @override
  Widget build(BuildContext context) {
    if (_isExpandedByUser(panel, allPanels, context) ||
        (panel.expanded ?? false)) {
      return KnowledgePanelExpandedCard(
        panel: panel,
        allPanels: allPanels,
      );
    }

    final KnowledgePanelPanelGroupElement? group =
        KnowledgePanelGroupCard.groupElementOf(context);

    return InkWell(
      child: KnowledgePanelSummaryCard(
        panel,
        isClickable: true,
      ),
      onTap: () {
        Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => KnowledgePanelPage(
              groupElement: group,
              panel: panel,
              allPanels: allPanels,
            ),
          ),
        );
      },
    );
  }

  bool _isExpandedByUser(
    final KnowledgePanel panel,
    final KnowledgePanels allPanels,
    BuildContext context,
  ) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    if (panel.titleElement != null &&
        panel.titleElement!.title ==
            allPanels.panelIdToPanelMap[EXPAND_PANEL_NUTRITION_TABLE_ID]
                ?.titleElement?.title) {
      if (userPreferences.expandedPanelNutritionsTable) {
        return true;
      }
    } else if (panel.titleElement != null &&
        panel.titleElement!.title ==
            allPanels.panelIdToPanelMap[EXPAND_PANEL_INGREDIENTS_ID]
                ?.titleElement?.title) {
      if (userPreferences.expandedPanelIngredients) {
        return true;
      }
    }
    return false;
  }
}
