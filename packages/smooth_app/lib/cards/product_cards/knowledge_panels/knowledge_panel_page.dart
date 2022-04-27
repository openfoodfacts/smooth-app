import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:smooth_app/cards/product_cards/knowledge_panels/knowledge_panel_expanded_card.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class KnowledgePanelPage extends StatelessWidget {
  const KnowledgePanelPage({
    required this.panel,
    required this.allPanels,
  });

  final KnowledgePanel panel;
  final KnowledgePanels allPanels;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: SmoothTheme.getColor(
        themeData.colorScheme,
        SmoothTheme.getMaterialColor(context),
        ColorDestination.SURFACE_BACKGROUND,
      ),
      appBar: AppBar(
        title: Text(panel.titleElement!.title),
      ),
      body: SingleChildScrollView(
        child: SmoothCard(
          padding: const EdgeInsets.all(
            SMALL_SPACE,
          ),
          child: KnowledgePanelExpandedCard(
            panel: panel,
            allPanels: allPanels,
          ),
        ),
      ),
    );
  }
}
