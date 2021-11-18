import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';

enum ProductCompatibility {
  UNKNOWN,
  INCOMPATIBLE,
  BAD_COMPATIBILITY,
  NEUTRAL_COMPATIBILITY,
  GOOD_COMPATIBILITY,
}

const int _BAD_COMPATIBILITY_UPPER_THRESHOLD = 33;
const int _NEUTRAL_COMPATIBILITY_UPPER_THRESHOLD = 66;

// Defines the weight of an attribute while computing the average match score
// for the product. The weight depends upon it's importance set in user prefs.
const Map<String, int> attributeImportanceWeight = <String, int>{
  PreferenceImportance.ID_MANDATORY: 4,
  PreferenceImportance.ID_VERY_IMPORTANT: 2,
  PreferenceImportance.ID_IMPORTANT: 1,
  PreferenceImportance.ID_NOT_IMPORTANT: 0,
};

Color getProductCompatibilityHeaderBackgroundColor(
    ProductCompatibility compatibility) {
  switch (compatibility) {
    case ProductCompatibility.UNKNOWN:
      return Colors.grey;
    case ProductCompatibility.INCOMPATIBLE:
      return Colors.red;
    case ProductCompatibility.BAD_COMPATIBILITY:
      return Colors.orangeAccent;
    case ProductCompatibility.NEUTRAL_COMPATIBILITY:
      return Colors.amber;
    case ProductCompatibility.GOOD_COMPATIBILITY:
      return Colors.green;
  }
}

String getProductCompatibilityHeaderTextWidget(
  ProductCompatibility compatibility,
) {
  // TODO(jasmeetsingh): This text should be internationalized.
  switch (compatibility) {
    case ProductCompatibility.UNKNOWN:
      return 'Product Compatibility Unknown';
    case ProductCompatibility.INCOMPATIBLE:
      return 'Very poor Match';
    case ProductCompatibility.BAD_COMPATIBILITY:
      return 'Poor Match';
    case ProductCompatibility.NEUTRAL_COMPATIBILITY:
      return 'Neutral Match';
    case ProductCompatibility.GOOD_COMPATIBILITY:
      return 'Great Match';
  }
}

ProductCompatibility getProductCompatibility(
  ProductPreferences productPreferences,
  Product product,
) {
  double averageAttributeMatch = 0.0;
  int numAttributesComputed = 0;
  for (final AttributeGroup group in product.attributeGroups!) {
    for (final Attribute attribute in group.attributes!) {
      final String importanceLevel =
          productPreferences.getImportanceIdForAttributeId(attribute.id!);
      // Check whether any mandatory attribute is incompatible
      if (importanceLevel == PreferenceImportance.ID_MANDATORY &&
          getAttributeEvaluation(attribute) == AttributeEvaluation.VERY_BAD) {
        return ProductCompatibility.INCOMPATIBLE;
      }
      if (!attributeImportanceWeight.containsKey(importanceLevel)) {
        // Unknown attribute importance level. (This should ideally never happen).
        // TODO(jasmeetsingh): [importanceLevel] should be an enum not a string.
        continue;
      }
      if (!isMatchAvailable(attribute)) {
        continue;
      }
      averageAttributeMatch +=
          attribute.match! * attributeImportanceWeight[importanceLevel]!;
      numAttributesComputed++;
    }
  }
  averageAttributeMatch /= numAttributesComputed;
  if (averageAttributeMatch < _BAD_COMPATIBILITY_UPPER_THRESHOLD) {
    return ProductCompatibility.BAD_COMPATIBILITY;
  }
  if (averageAttributeMatch < _NEUTRAL_COMPATIBILITY_UPPER_THRESHOLD) {
    return ProductCompatibility.NEUTRAL_COMPATIBILITY;
  }
  return ProductCompatibility.GOOD_COMPATIBILITY;
}
