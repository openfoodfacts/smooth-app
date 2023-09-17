import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_page.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class KnowledgePanelCard extends StatelessWidget {
  const KnowledgePanelCard({
    required this.panelId,
    required this.product,
  });

  final String panelId;
  final Product product;

  static const String PANEL_NUTRITION_TABLE_ID = 'nutrition_facts_table';
  static const String PANEL_INGREDIENTS_ID = 'ingredients';

  /// Returns the preferences tag we use for the flag related to that [panelId].
  static String getExpandFlagTag(final String panelId) => 'expand_$panelId';

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final KnowledgePanel? panel =
        KnowledgePanelsBuilder.getKnowledgePanel(product, panelId);
    if (panel == null) {
      return EMPTY_WIDGET;
    }
    if (_isExpandedByUser(panel, userPreferences) || (panel.expanded == true)) {
      return KnowledgePanelExpandedCard(
        panelId: panelId,
        product: product,
        isInitiallyExpanded: false,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: InkWell(
        borderRadius: ANGULAR_BORDER_RADIUS,
        child: KnowledgePanelsBuilder.getPanelSummaryWidget(
          panel,
          isClickable: true,
          margin: EdgeInsets.zero,
        ),
        onTap: () async => Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => SmoothBrightnessOverride(
              brightness: SmoothBrightnessOverride.of(context)?.brightness,
              child: KnowledgePanelPage(
                panelId: panelId,
                product: product,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isExpandedByUser(
    final KnowledgePanel panel,
    final UserPreferences userPreferences,
  ) {
    final List<String> expandedPanelIds = <String>[
      PANEL_NUTRITION_TABLE_ID,
      PANEL_INGREDIENTS_ID,
    ];
    for (final String panelId in expandedPanelIds) {
      if (panel.titleElement != null &&
          panel.titleElement!.title ==
              KnowledgePanelsBuilder.getKnowledgePanel(product, panelId)
                  ?.titleElement
                  ?.title) {
        if (userPreferences.getFlag(getExpandFlagTag(panelId)) ?? false) {
          return true;
        }
      }
    }
    return false;
  }
}
