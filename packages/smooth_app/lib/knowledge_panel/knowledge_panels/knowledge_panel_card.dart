import 'package:flutter/foundation.dart';
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
    required this.isClickable,
  });

  final String panelId;
  final Product product;
  final bool isClickable;

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
        isClickable: isClickable,
      );
    }

    // in some cases there's nothing to click about.
    // cf. https://github.com/openfoodfacts/smooth-app/issues/5700
    final bool improvedIsClickable = isClickable &&
        KnowledgePanelsBuilder.hasSomethingToDisplay(
          product,
          panelId,
        );
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: SMALL_SPACE,
      ),
      child: InkWell(
        borderRadius: ANGULAR_BORDER_RADIUS,
        onTap: !improvedIsClickable
            ? null
            : () async => Navigator.push<Widget>(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) => SmoothBrightnessOverride(
                      brightness:
                          SmoothBrightnessOverride.of(context)?.brightness,
                      child: KnowledgePanelPage(
                        panelId: panelId,
                        product: product,
                      ),
                    ),
                  ),
                ),
        child: KnowledgePanelsBuilder.getPanelSummaryWidget(
              panel,
              isClickable: improvedIsClickable,
              margin: EdgeInsets.zero,
            ) ??
            const SizedBox(),
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('panelId', panelId));
    properties.add(DiagnosticsProperty<bool>('clickable', isClickable));
  }
}
