/// Helper around knowledge panel ids.
///
/// cf. product.knowledgePanels!.panelIdToPanelMap.keys
enum KnowledgePanelEnum {
  nutriscore('nutriscore'),
  fat('nutrient_level_fat'),
  saturatedFat('nutrient_level_saturated-fat'),
  sugar('nutrient_level_sugars'),
  salt('nutrient_level_salt'),
  nutritionFacts('nutrition_facts_table'),
  servingSize('serving_size'),
  ingredients('ingredients'),
  nova('nova'),
  palmOil('ingredients_analysis_en:palm-oil-free'),
  vegan('ingredients_analysis_en:vegan'),
  vegetarian('ingredients_analysis_en:vegetarian'),
  ingredientsAnalysis('ingredients_analysis_details'),
  ecoscore('ecoscore'),
  recycling('packaging_recycling'),
  origins('origins_of_ingredients');

  const KnowledgePanelEnum(this.id);

  final String id;
}
