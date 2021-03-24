import 'package:meta/meta.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:smooth_app/temp/preference_importance.dart';
import 'package:smooth_app/temp/available_preference_importances.dart';
import 'package:smooth_app/temp/available_product_preferences.dart';
import 'package:smooth_app/temp/product_preferences_selection.dart';

/// Manager of the product preferences: referential and app/user preferences.
class ProductPreferencesManager {
  ProductPreferencesManager(this._productPreferencesSelection);

  final ProductPreferencesSelection _productPreferencesSelection;
  AvailableProductPreferences _availableProductPreferences;

  @protected
  set availableProductPreferences(
    AvailableProductPreferences availableProductPreferences,
  ) =>
      _availableProductPreferences = availableProductPreferences;

  /// Returns the attribute from the localized referential.
  Attribute getReferenceAttribute(final String attributeId) {
    for (final AttributeGroup attributeGroup in attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        if (attribute.id == attributeId) {
          return attribute;
        }
      }
    }
    return null;
  }

  List<AttributeGroup> get attributeGroups =>
      _availableProductPreferences.availableAttributeGroups.attributeGroups;

  AvailablePreferenceImportances get _availablePreferenceImportances =>
      _availableProductPreferences.availablePreferenceImportances;

  List<String> get importanceIds =>
      _availablePreferenceImportances.importanceIds;

  String getImportanceIdForAttributeId(String attributeId) =>
      _productPreferencesSelection.getImportance(attributeId);

  Future<void> setImportance(
    final String attributeId,
    final String importanceId, {
    final bool notifyListeners = true,
  }) async {
    await _productPreferencesSelection.setImportance(
      attributeId,
      importanceId,
    );
    if (notifyListeners) {
      notify();
    }
  }

  /// Returns all important attributes, ordered by descending importance.
  List<String> getOrderedImportantAttributeIds() {
    final Map<int, List<String>> map = <int, List<String>>{};
    for (final AttributeGroup attributeGroup in attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        final String attributeId = attribute.id;
        final String importanceId = getImportanceIdForAttributeId(attributeId);
        final int importanceIndex =
            _availablePreferenceImportances.getImportanceIndex(importanceId);
        if (importanceIndex == PreferenceImportance.INDEX_NOT_IMPORTANT) {
          continue;
        }
        List<String> list = map[importanceIndex];
        if (list == null) {
          list = <String>[];
          map[importanceIndex] = list;
        }
        list.add(attributeId);
      }
    }
    final List<String> result = <String>[];
    if (map.isEmpty) {
      return result;
    }
    final List<int> decreasingImportances = <int>[];
    decreasingImportances.addAll(map.keys);
    decreasingImportances.sort((int a, int b) => b - a);
    for (final int importance in decreasingImportances) {
      final List<String> list = map[importance];
      list.forEach(result.add);
    }
    return result;
  }

  PreferenceImportance getPreferenceImportanceFromImportanceId(
    final String importanceId,
  ) {
    return _availablePreferenceImportances.getPreferenceImportance(
      importanceId,
    );
  }

  int getImportanceIndex(final String importanceId) =>
      _availablePreferenceImportances.getImportanceIndex(
        importanceId,
      );

  void notify() => _productPreferencesSelection.notify();

  Future<void> clearImportances({final bool notifyListeners = true}) async {
    for (final AttributeGroup attributeGroup in attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        await setImportance(
          attribute.id,
          PreferenceImportance.ID_NOT_IMPORTANT,
          notifyListeners: false,
        );
      }
    }
    if (notifyListeners) {
      notify();
    }
  }
}
