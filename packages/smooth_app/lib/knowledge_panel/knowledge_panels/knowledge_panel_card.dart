import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_group_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_summary_card.dart';

class KnowledgePanelCard extends StatelessWidget {
  const KnowledgePanelCard({
    required this.panel,
    required this.allPanels,
    required this.product,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;
  final Product product;

  static const String PANEL_NUTRITION_TABLE_ID = 'nutrition_facts_table';
  static const String PANEL_INGREDIENTS_ID = 'ingredients';

  /// Returns the preferences tag we use for the flag related to that [panelId].
  static String getExpandFlagTag(final String panelId) => 'expand_$panelId';

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    if (_isExpandedByUser(panel, allPanels, userPreferences) ||
        (panel.expanded ?? false)) {
      return KnowledgePanelExpandedCard(
        panel: panel,
        allPanels: allPanels,
        product: product,
        isInitiallyExpanded: false,
      );
    }

    final KnowledgePanelPanelGroupElement? group =
        KnowledgePanelGroupCard.groupElementOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: InkWell(
        borderRadius: ANGULAR_BORDER_RADIUS,
        child: KnowledgePanelSummaryCard(
          panel,
          isClickable: true,
          margin: EdgeInsets.zero,
        ),
        onTap: () {
          Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => KnowledgePanelPage(
                groupElement: group,
                panel: panel,
                allPanels: allPanels,
                product: product,
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isExpandedByUser(
    final KnowledgePanel panel,
    final KnowledgePanels allPanels,
    final UserPreferences userPreferences,
  ) {
    final List<String> expandedPanelIds = <String>[
      PANEL_NUTRITION_TABLE_ID,
      PANEL_INGREDIENTS_ID,
    ];
    for (final String panelId in expandedPanelIds) {
      if (panel.titleElement != null &&
          panel.titleElement!.title ==
              allPanels.panelIdToPanelMap[panelId]?.titleElement?.title) {
        if (userPreferences.getFlag(getExpandFlagTag(panelId)) ?? false) {
          return true;
        }
      }
    }
    return false;
  }
}
