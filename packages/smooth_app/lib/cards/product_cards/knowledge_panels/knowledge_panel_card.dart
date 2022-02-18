import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_summary_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class KnowledgePanelCard extends StatelessWidget {
  const KnowledgePanelCard({
    required this.panel,
    required this.allPanels,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData themeData = Theme.of(context);
    // If [expanded] = true, render all panel elements (including summary), otherwise just renders panel summary.
    if (panel.expanded ?? false) {
      return KnowledgePanelExpandedCard(
        panel: panel,
        allPanels: allPanels,
      );
    }
    return InkWell(
      child: KnowledgePanelSummaryCard(panel),
      onTap: () {
        AnalyticsHelper.trackKnowledgePanelOpen(
          knowledgePanelName: panel.topics.toString(),
        );
        Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => Scaffold(
              backgroundColor: SmoothTheme.getColor(
                themeData.colorScheme,
                SmoothTheme.getMaterialColor(themeProvider),
                ColorDestination.SURFACE_BACKGROUND,
              ),
              appBar: AppBar(),
              body: SingleChildScrollView(
                child: SmoothCard(
                  color: const Color(0xfff5f6fa),
                  padding: const EdgeInsets.all(
                    SMALL_SPACE,
                  ),
                  child: KnowledgePanelExpandedCard(
                    panel: panel,
                    allPanels: allPanels,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
