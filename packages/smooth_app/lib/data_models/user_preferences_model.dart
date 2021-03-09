// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:smooth_app/temp/user_preferences.dart';

class UserPreferencesModel extends ChangeNotifier {
  UserPreferencesModel._();

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

  static const String _DEFAULT_LANGUAGE = 'en';

  static String _getImportanceAssetPath(final String languageCode) =>
      'assets/metadata/init_preferences_$languageCode.json';
  static String _getAttributeAssetPath(final String languageCode) =>
      'assets/metadata/init_attribute_groups_$languageCode.json';
  static String _getImportanceUrl(final String languageCode) =>
      'https://world.openfoodfacts.org/api/v2/preferences?lc=$languageCode';
  static String _getAttributeUrl(final String languageCode) =>
      'https://world.openfoodfacts.org/api/v2/attribute_groups?lc=$languageCode';

  static Future<UserPreferencesModel> getUserPreferencesModel(
          final AssetBundle assetBundle) async =>
      _getAssets(assetBundle, _DEFAULT_LANGUAGE);

  List<PreferencesValue> _preferenceValues;
  Map<String, int> _preferenceValuesReverse;
  List<AttributeGroup> _attributeGroups;
  String _languageCode;
  bool _isHttps;

  List<AttributeGroup> get attributeGroups => _attributeGroups;
  String get languageCode => _languageCode;

  // TODO(monsieurtanuki): add a "previously downloaded file" cache layer
  // TODO(monsieurtanuki): avoid an endless refresh (e.g. if no internet connection)
  Future<void> refresh(
    final AssetBundle assetBundle,
    final String languageCode,
  ) async {
    if (_languageCode != languageCode) {
      final UserPreferencesModel other =
          await _getAssets(assetBundle, languageCode);
      if (other != null) {
        _copyFrom(other);
      }
    }
    if (!_isHttps) {
      final UserPreferencesModel other = await _getHttps(languageCode);
      if (other != null) {
        _copyFrom(other);
      }
    }
  }

  void _copyFrom(final UserPreferencesModel other) {
    _languageCode = other._languageCode;
    _isHttps = other._isHttps;
    _preferenceValues = other._preferenceValues;
    _preferenceValuesReverse = other._preferenceValuesReverse;
    _attributeGroups = other._attributeGroups;
    notifyListeners();
  }

  bool _loadStrings(
    final String importanceString,
    final String attributeGroupString,
  ) {
    try {
      if (!_loadJsonString(importanceString, _loadValues)) {
        return false;
      }
      if (!_loadJsonString(attributeGroupString, _loadAttributeGroups)) {
        return false;
      }
      return true;
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      return false;
    }
  }

  static Future<UserPreferencesModel> _getAssets(
    final AssetBundle assetBundle,
    final String languageCode,
  ) async {
    String importanceString;
    String attributeGroupString;
    try {
      importanceString =
          await assetBundle.loadString(_getImportanceAssetPath(languageCode));
      attributeGroupString =
          await assetBundle.loadString(_getAttributeAssetPath(languageCode));
    } catch (e) {
      /// we don't have all the languages in the assets
      return null;
    }
    try {
      final UserPreferencesModel userPreferencesModel =
          UserPreferencesModel._();
      userPreferencesModel._languageCode = languageCode;
      userPreferencesModel._isHttps = false;
      if (userPreferencesModel._loadStrings(
          importanceString, attributeGroupString)) {
        return userPreferencesModel;
      }
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
    }
    return null;
  }

  static Future<UserPreferencesModel> _getHttps(
    final String languageCode,
  ) async {
    try {
      final String importanceUrl = _getImportanceUrl(languageCode);
      final String attributeUrl = _getAttributeUrl(languageCode);
      http.Response response;
      response = await http.get(Uri.parse(importanceUrl));
      // TODO(monsieurtanuki): check response.statusCode
      final String importanceString = response.body;
      response = await http.get(Uri.parse(attributeUrl));
      // TODO(monsieurtanuki): check response.statusCode
      final String attributeGroupString = response.body;
      final UserPreferencesModel userPreferencesModel =
          UserPreferencesModel._();
      userPreferencesModel._languageCode = languageCode;
      userPreferencesModel._isHttps = true;
      if (userPreferencesModel._loadStrings(
          importanceString, attributeGroupString)) {
        return userPreferencesModel;
      }
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
    }
    return null;
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

  static Attribute getAttribute(
    final Product product,
    final String attributeId,
  ) {
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
        // TODO(monsieurtanuki): have it fixed upstream
        if (attribute.id == 'palm-oil-free' && attributeId == 'palm_oil_free') {
          return attribute;
        }
      }
    }
    return null;
  }

  Attribute getReferenceAttribute(final String attributeId) {
    for (final AttributeGroup attributeGroup in _attributeGroups) {
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

  void _loadAttributeGroups(dynamic json) =>
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
