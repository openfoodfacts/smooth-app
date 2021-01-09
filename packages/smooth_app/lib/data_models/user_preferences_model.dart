import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';

class UserPreferencesModel extends ChangeNotifier {
  UserPreferencesModel._();

  static Future<UserPreferencesModel> getUserPreferencesModel(
      final BuildContext context) async {
    final UserPreferencesModel result = UserPreferencesModel._();
    final bool ok = await result._loadAssets(context);
    return ok ? result : null;
  }

  List<PreferencesValue> _preferenceValues;
  Map<String, int> _preferenceValuesReverse;
  List<AttributeGroup> _attributeGroups;

  List<AttributeGroup> get attributeGroups => _attributeGroups;

  bool _loadStrings(
      final String importanceString, final String variableString) {
    try {
      if (!_loadJsonString(importanceString, _loadValues)) {
        return false;
      }
      if (!_loadJsonString(variableString, _loadVariables)) {
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      return false;
    }
  }

  Future<bool> _loadAssets(final BuildContext context) async {
    try {
      final String importanceString = await DefaultAssetBundle.of(context)
          .loadString('assets/metadata/init_preferences.json');
      final String variableString = await DefaultAssetBundle.of(context)
          .loadString('assets/metadata/init_attribute_groups.json');
      return _loadStrings(importanceString, variableString);
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      return false;
    }
  }

  bool _loadJsonString(final String inputString, final Function fromJson) {
    try {
      final dynamic inputJson = json.decode(inputString);
      fromJson(inputJson);
      return true;
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      return false;
    }
  }

  List<String> getOrderedVariables(final UserPreferences userPreferences) {
    final Map<int, List<String>> map = <int, List<String>>{};
    for (final AttributeGroup attributeGroup in attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        final String variable = attribute.id;
        final int importance =
            getAttributeValueIndex(variable, userPreferences);
        if (importance == null ||
            importance == UserPreferences.INDEX_NOT_IMPORTANT) {
          continue;
        }
        List<String> list = map[importance];
        if (list == null) {
          list = <String>[];
          map[importance] = list;
        }
        list.add(variable);
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

  Attribute getAttribute(final Product product, final String attributeId) {
    if (product == null) {
      return null;
    }
    if (attributeId == null) {
      return null;
    }
    if (product.attributeGroups == null) {
      return null;
    }
    for (final AttributeGroup attributeGroup in product.attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        if (attribute.id == attributeId) {
          return attribute;
        }
      }
    }
    return null;
  }

  int getAttributeValueIndex(
    final String variable,
    final UserPreferences userPreferences,
  ) =>
      getValueIndex(getPreferencesValue(variable, userPreferences).id);

  int getValueIndex(final String value) =>
      _preferenceValuesReverse[value] ?? UserPreferences.INDEX_NOT_IMPORTANT;

  PreferencesValue getPreferencesValue(
    final String variable,
    final UserPreferences userPreferences,
  ) =>
      _preferenceValues[userPreferences.getImportance(variable)];

  void _loadValues(dynamic json) {
    _preferenceValues = (json as List<dynamic>)
        .map((dynamic item) => PreferencesValue.fromJson(item))
        .toList();
    _preferenceValuesReverse = <String, int>{};
    int i = 0;
    for (final PreferencesValue preferencesValue in _preferenceValues) {
      _preferenceValuesReverse[preferencesValue.id] = i++;
    }
  }

  void _loadVariables(dynamic json) =>
      _attributeGroups = (json as List<dynamic>)
          .map((dynamic item) => AttributeGroup.fromJson(item))
          .toList();
}

class PreferencesValue {
  PreferencesValue({this.id, this.name, this.factor, this.minimalMatch});

  factory PreferencesValue.fromJson(dynamic json) => PreferencesValue(
        id: json['id'] as String,
        name: json['name'] as String,
        factor: json['factor'] as int,
        minimalMatch: json['minimum_match'] as int,
      );

  final String id;
  final String name;
  final int factor;
  final int minimalMatch;

  @override
  String toString() => 'PreferencesValue('
      'id: $id, name: $name, factor: $factor, minimalWatch: $minimalMatch'
      ')';
}
