import 'dart:convert';
import 'package:openfoodfacts/model/AttributeGroup.dart';

/// Referential of attribute groups, with loader.
class AttributeGroupReferential {
  /// Load constructor; may throw an exception.
  AttributeGroupReferential.loadFromJSONString(
    final String attributeGroupString,
  ) {
    final dynamic inputJson = json.decode(attributeGroupString);
    final List<AttributeGroup> attributeGroups = <AttributeGroup>[];
    for (final dynamic item in inputJson as List<dynamic>) {
      attributeGroups.add(AttributeGroup.fromJson(item));
    }
    if (attributeGroups.isEmpty) {
      throw Exception(
          'Unexpected error: empty attribute groups from json string $attributeGroupString');
    }
    _attributeGroups = attributeGroups;
  }

  List<AttributeGroup> _attributeGroups;

  List<AttributeGroup> get attributeGroups => _attributeGroups;

  /// Where a localized JSON file can be found.
  /// [languageCode] is a 2-letter language code.
  static String getUrl(final String languageCode) =>
      'https://world.openfoodfacts.org/api/v2/attribute_groups?lc=$languageCode';

  static const String ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS =
      'ingredients_analysis';
  static const String ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY =
      'nutritional_quality';
  static const String ATTRIBUTE_GROUP_PROCESSING = 'processing';
  static const String ATTRIBUTE_GROUP_ALLERGENS = 'allergens';
  static const String ATTRIBUTE_GROUP_LABELS = 'labels';
  static const String ATTRIBUTE_GROUP_ENVIRONMENT = 'environment';

//  static const String ATTRIBUTE_VEGETARIAN = 'vegetarian';
//  static const String ATTRIBUTE_VEGAN = 'vegan';
//  static const String ATTRIBUTE_PALM_OIL_FREE = 'palm-oil-free';
  static const String ATTRIBUTE_NOVA = 'nova';
  static const String ATTRIBUTE_ADDITIVES = 'additives';
  static const String ATTRIBUTE_NUTRISCORE = 'nutriscore';
//  static const String ATTRIBUTE_LOW_SALT = 'low_salt';
//  static const String ATTRIBUTE_LOW_SUGARS = 'low_sugars';
//  static const String ATTRIBUTE_LOW_FAT = 'low_fat';
//  static const String ATTRIBUTE_LOW_SATURATED_FAT = 'low_saturated_fat';
  static const String ATTRIBUTE_ECOSCORE = 'ecoscore';
//  static const String ATTRIBUTE_ORGANIC = 'labels_organic';
//  static const String ATTRIBUTE_FAIR_TRADE = 'labels_fair_trade';
}
