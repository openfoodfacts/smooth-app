import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_controller.dart';

class FoodPreferencesAttributeConfig {
  const FoodPreferencesAttributeConfig._();

  static const Map<FoodPreferencesPageType, List<String>>
  pageToAttributeGroups = <FoodPreferencesPageType, List<String>>{
    FoodPreferencesPageType.diets: <String>[
      AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    ],
    FoodPreferencesPageType.allergies: <String>[
      AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
    ],
    FoodPreferencesPageType.unwantedFoods: <String>[
      AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
    ],
    FoodPreferencesPageType.foodsToAvoid: <String>[
      AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    ],
    FoodPreferencesPageType.environment: <String>[
      AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
      AttributeGroup.ATTRIBUTE_GROUP_LABELS,
    ],
  };
  static List<String> getAttributeGroupIds(FoodPreferencesPageType pageType) {
    return pageToAttributeGroups[pageType] ?? <String>[];
  }

  static List<AttributeGroup> filterGroupsForPage(
    List<AttributeGroup> allGroups,
    FoodPreferencesPageType pageType,
  ) {
    final List<String> groupIds = getAttributeGroupIds(pageType);
    if (groupIds.isEmpty) {
      return <AttributeGroup>[];
    }

    return allGroups
        .where((AttributeGroup group) => groupIds.contains(group.id))
        .toList();
  }

  static List<Attribute> getAttributesForPage(
    List<AttributeGroup> allGroups,
    FoodPreferencesPageType pageType,
  ) {
    final List<AttributeGroup> filteredGroups = filterGroupsForPage(
      allGroups,
      pageType,
    );

    final List<Attribute> attributes = <Attribute>[];
    for (final AttributeGroup group in filteredGroups) {
      if (group.attributes != null) {
        attributes.addAll(group.attributes!);
      }
    }
    return attributes;
  }

  static bool hasAttributes(FoodPreferencesPageType pageType) {
    return pageToAttributeGroups.containsKey(pageType);
  }
}
