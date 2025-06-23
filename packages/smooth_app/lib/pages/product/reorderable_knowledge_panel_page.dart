import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page where the user can reorder the Knowledge Panel Cards.
class ReorderableKnowledgePanelPage extends StatefulWidget {
  const ReorderableKnowledgePanelPage(this.product);

  final Product product;

  static List<String> getOrderedKnowledgePanels(
    final UserPreferences userPreferences,
  ) {
    final List<String> order = userPreferences.userKnowledgePanelOrder;
    if (order.isNotEmpty) {
      return order;
    }
    return List<String>.from(ReorderableKnowledgePanelPage._initialOrder,
        growable: true);
  }

  // cf. product.knowledgePanels!.panelIdToPanelMap.keys
  // TODO(monsieurtanuki): check how safe it is. What about new entries from the server? What about missing entries for a product?
  static const List<String> _initialOrder = <String>[
    'nutriscore',
    'nutrient_level_fat',
    'nutrient_level_saturated-fat',
    'nutrient_level_sugars',
    'nutrient_level_salt',
    'nutrition_facts_table',
    'serving_size',
    'ingredients',
    'nova',
//    'environment_card',
//    'health_card',
    'ingredients_analysis_en:palm-oil-free',
    'ingredients_analysis_en:vegan',
    'ingredients_analysis_en:vegetarian',
//    'ingredients_analysis',
    'ingredients_analysis_details',
    'ecoscore',
//    'packaging_components',
//    'packaging_materials',
    'packaging_recycling',
    'origins_of_ingredients',
//    'root',
  ];

  @override
  State<ReorderableKnowledgePanelPage> createState() =>
      _ReorderableKnowledgePanelPageState();
}

class _ReorderableKnowledgePanelPageState
    extends State<ReorderableKnowledgePanelPage> {
  late List<String> _order;

  void _initOrder(final BuildContext context) {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    _order = ReorderableKnowledgePanelPage.getOrderedKnowledgePanels(
      userPreferences,
    );
  }

  Future<void> _setOrder() async {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    await userPreferences.setUserKnowledgePanelOrder(_order);
  }

  @override
  void initState() {
    super.initState();
    _initOrder(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    int index = 0;
    for (final String panelId in _order) {
      children.add(
        ListTile(
          key: Key(panelId),
          title: KnowledgePanelCard(
            panelId: panelId,
            product: widget.product,
            isClickable: false,
          ),
          trailing: ReorderableDragStartListener(
            key: ValueKey<int>(index),
            index: index++,
            child: const Icon(Icons.drag_handle),
          ),
        ),
      );
    }
    return SmoothScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).reorder_attribute_action),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              _order = <String>[];
              await _setOrder();
              if (!context.mounted) {
                return;
              }
              setState(() => _initOrder(context));
            },
          )
        ],
      ),
      body: ReorderableListView(
        buildDefaultDragHandles: false,
        children: children,
        onReorder: (int oldIndex, int newIndex) => setState(
          () {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final String item = _order.removeAt(oldIndex);
            _order.insert(newIndex, item);
            _setOrder();
          },
        ),
      ),
    );
  }
}
