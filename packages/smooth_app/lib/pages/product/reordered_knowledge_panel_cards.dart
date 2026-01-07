import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/product/reorderable_knowledge_panel_page.dart';

/// Knowledge Panel Cards as reordered by the user.
class ReorderedKnowledgePanelCards extends StatelessWidget {
  const ReorderedKnowledgePanelCards(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final List<String> order =
        ReorderableKnowledgePanelPage.getOrderedKnowledgePanels(
          userPreferences,
        );
    final List<Widget> children = <Widget>[];
    for (final String panelId in order) {
      children.add(
        ListTile(
          title: KnowledgePanelCard(
            panelId: panelId,
            product: product,
            isClickable: true,
          ),
        ),
      );
    }
    return Column(children: children);
  }
}
