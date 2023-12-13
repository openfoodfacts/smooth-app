import 'package:smooth_app/data_models/preferences/user_preferences.dart';

/// Model to manage KP items - which are to reorder and how.
class ReorderableKnowledgePanelModel {
  ReorderableKnowledgePanelModel(this.userPreferences)
      : selected = _getSelected(userPreferences),
        ordered = getList(userPreferences);

  final UserPreferences userPreferences;

  final Set<String> selected;

  final List<String> ordered;

  static Set<String> _getSelected(final UserPreferences userPreferences) {
    final Set<String> result = <String>{};
    result.addAll(userPreferences.userKnowledgePanelSelected);
    return result;
  }

  static List<String> getList(final UserPreferences userPreferences) =>
      userPreferences.userKnowledgePanelOrder;

  Future<void> saveSelected() async {
    await userPreferences.setUserKnowledgePanelSelected(
      List<String>.of(selected),
    );
    await saveOrder();
  }

  Future<void> saveOrder() async =>
      userPreferences.setUserKnowledgePanelOrder(ordered);

  void removeSelected(final String value) {
    selected.remove(value);
    ordered.remove(value);
  }

  void addSelected(final String value) {
    selected.add(value);
    ordered.add(value);
  }

  void clearSelected() {
    selected.clear();
    ordered.clear();
  }

  // cf. product.knowledgePanels!.panelIdToPanelMap.keys
  // TODO(monsieurtanuki): check how safe it is. What about new entries from the server? What about missing entries for a product?
  static const List<String> initialOrder = <String>[
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

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, item);
  }
}
