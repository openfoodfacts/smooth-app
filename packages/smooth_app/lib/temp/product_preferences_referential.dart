import 'package:smooth_app/temp/attribute_group_referential.dart';
import 'package:smooth_app/temp/preference_importance_referential.dart';

/// Referential for product preferences: attribute groups and importance.
class ProductPreferencesReferential {
  /// Load constructor - may throw an exception.
  ProductPreferencesReferential.loadFromJSONStrings(
    final String importanceString,
    final String attributeGroupString,
  ) {
    final AttributeGroupReferential attributeGroupReferential =
        AttributeGroupReferential.loadFromJSONString(attributeGroupString);
    final PreferenceImportanceReferential preferenceImportanceReferential =
        PreferenceImportanceReferential.loadFromJSONString(importanceString);
    _attributeGroupReferential = attributeGroupReferential;
    _preferenceImportanceReferential = preferenceImportanceReferential;
  }

  AttributeGroupReferential _attributeGroupReferential;
  AttributeGroupReferential get attributeGroupReferential =>
      _attributeGroupReferential;

  PreferenceImportanceReferential _preferenceImportanceReferential;
  PreferenceImportanceReferential get preferenceImportanceReferential =>
      _preferenceImportanceReferential;
}
