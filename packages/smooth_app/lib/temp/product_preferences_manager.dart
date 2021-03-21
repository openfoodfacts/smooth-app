import 'package:meta/meta.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:smooth_app/temp/attribute_group_referential.dart';
import 'package:smooth_app/temp/preference_importance.dart';
import 'package:smooth_app/temp/product_preferences_referential.dart';
import 'package:smooth_app/temp/product_preferences_selection.dart';
import 'package:openfoodfacts/model/Attribute.dart';

/// Manager of the product preferences: referential and app/user preferences.
class ProductPreferencesManager {
  ProductPreferencesManager(this._productPreferencesSelection);

  final ProductPreferencesSelection _productPreferencesSelection;
  ProductPreferencesReferential _productPreferencesRepository;

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
      _productPreferencesRepository.attributeGroupReferential.attributeGroups;

  List<String> get importanceIds => _productPreferencesRepository
      .preferenceImportanceReferential.importanceIds;

  @protected
  set productPreferencesRepository(
          ProductPreferencesReferential productPreferencesRepository) =>
      _productPreferencesRepository = productPreferencesRepository;

  String getImportance(String attributeId) =>
      _productPreferencesSelection.getImportance(attributeId);

  Future<void> setImportance(
    final String attributeId,
    final String importanceId,
  ) async {
    await _productPreferencesSelection.setImportance(
      attributeId,
      importanceId,
    );
    _productPreferencesSelection.notify();
  }

  /// Returns all important attributes, ordered by descending importance.
  List<String> getOrderedImportantAttributeIds() {
    final Map<int, List<String>> map = <int, List<String>>{};
    for (final AttributeGroup attributeGroup in _productPreferencesRepository
        .attributeGroupReferential.attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        final String attributeId = attribute.id;
        final String importanceId = getImportance(attributeId);
        final int importanceIndex = _productPreferencesRepository
            .preferenceImportanceReferential
            .getImportanceIndex(importanceId);
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

  PreferenceImportance getPreferenceImportance(final String importanceId) {
    return _productPreferencesRepository.preferenceImportanceReferential
        .getPreferenceImportance(importanceId);
  }

  Future<void> resetImportances() async {
    for (final AttributeGroup attributeGroup in attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        await _productPreferencesSelection.setImportance(
          attribute.id,
          PreferenceImportance.ID_NOT_IMPORTANT,
        );
      }
    }
    await _productPreferencesSelection.setImportance(
      AttributeGroupReferential.ATTRIBUTE_NUTRISCORE,
      PreferenceImportance.ID_VERY_IMPORTANT,
    );
    await _productPreferencesSelection.setImportance(
      AttributeGroupReferential.ATTRIBUTE_NOVA,
      PreferenceImportance.ID_IMPORTANT,
    );
    await _productPreferencesSelection.setImportance(
      AttributeGroupReferential.ATTRIBUTE_ECOSCORE,
      PreferenceImportance.ID_IMPORTANT,
    );
    notify();
  }

  int getImportanceIndex(final String importanceId) =>
      _productPreferencesRepository.preferenceImportanceReferential
          .getImportanceIndex(
        importanceId,
      );

  void notify() => _productPreferencesSelection.notify();
}
