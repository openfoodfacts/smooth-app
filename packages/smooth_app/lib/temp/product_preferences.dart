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
import 'package:smooth_app/temp/preference_importance.dart';

/// Where we store all product attribute groups and importance.
///
/// At init time we need to load from json the localized reference data
/// for importance and attribute groups.
/// We also need to store the app or user preferences regarding importance,
/// e.g. 'nutriscore' is 'very_important' and 'ecoscore' is 'mandatory',
/// but we cannot decide here how to store those preferences and rather let
/// the developer implement [saveImportance] and [loadImportance]
class ProductPreferences extends ChangeNotifier {
  ProductPreferences(this.saveImportance, this.loadImportance);

  /// Saves the importance of an attribute, e.g. in a SharedPreferences.
  ///
  /// Ex:
  /// ```dart
  /// (String attributeId, int importanceIndex) async =>
  ///     await mySharedPreferences.setInt(attributeId, importanceIndex);
  /// ```
  final Future<void> Function(
    String attributeId,
    int importanceIndex,
  ) saveImportance;

  /// Loads the importance of an attribute, e.g. from a SharedPreferences.
  ///
  /// Ex:
  /// ```dart
  /// (String attributeId) =>
  ///     mySharedPreferences.getInt(attributeId)
  ///     ?? PreferenceImportance.INDEX_NOT_IMPORTANT;
  /// ```
  final int Function(String attributeId) loadImportance;

  /// 2-letter language code of the latest reference load.
  String _languageCode;

  /// "was it a https load" bool of the latest reference load.
  bool _isHttps;

  String get languageCode => _languageCode;
  bool get isHttps => _isHttps;

  List<PreferenceImportance> _preferenceImportances;
  Map<String, int> _preferenceImportancesReverse;
  List<AttributeGroup> _attributeGroups;

  List<AttributeGroup> get attributeGroups => _attributeGroups;

  // TODO(stephanegigandet): move to AttributeGroup?
  static const String ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS =
      'ingredients_analysis';
  static const String ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY =
      'nutritional_quality';
  static const String ATTRIBUTE_GROUP_PROCESSING = 'processing';
  static const String ATTRIBUTE_GROUP_ALLERGENS = 'allergens';
  static const String ATTRIBUTE_GROUP_LABELS = 'labels';
  static const String ATTRIBUTE_GROUP_ENVIRONMENT = 'environment';

  // TODO(stephanegigandet): move to Attribute?
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

  // TODO(monsieurtanuki): put in AttributeGroup?
  static String _getAttributeUrl(final String languageCode) =>
      'https://world.openfoodfacts.org/api/v2/attribute_groups?lc=$languageCode';

  @override
  void notifyListeners() => super.notifyListeners();

  /// Loads the references of importance and attribute groups from assets.
  Future<bool> loadReferenceFromAssets(
    final AssetBundle assetBundle,
    final String languageCode,
    final String importanceAssetPath,
    final String attributeGroupAssetPath,
  ) async {
    String importanceString;
    String attributeGroupString;
    try {
      importanceString = await assetBundle.loadString(importanceAssetPath);
      attributeGroupString =
          await assetBundle.loadString(attributeGroupAssetPath);
      return loadReferenceFromStrings(
        importanceString,
        attributeGroupString,
        languageCode,
        false,
      );
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
    }
    return false;
  }

  /// Loads the references of importance and attribute groups from urls.
  Future<bool> loadReferenceFromHttps(
    final String languageCode, {
    String importanceUrl,
    String attributeGroupUrl,
  }) async {
    try {
      importanceUrl ??= PreferenceImportance.getUrl(languageCode);
      attributeGroupUrl ??= _getAttributeUrl(languageCode);
      http.Response response;
      response = await http.get(Uri.parse(importanceUrl));
      if (response.statusCode != 200) {
        return false;
      }
      final String importanceString = response.body;
      response = await http.get(Uri.parse(attributeGroupUrl));
      if (response.statusCode != 200) {
        return false;
      }
      final String attributeGroupString = response.body;
      return loadReferenceFromStrings(
        importanceString,
        attributeGroupString,
        languageCode,
        true,
      );
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
    }
    return false;
  }

  /// Loads the references of importance and attribute groups from json strings.
  bool loadReferenceFromStrings(
    final String importanceString,
    final String attributeGroupString,
    final String languageCode,
    final bool isHttps,
  ) {
    List<PreferenceImportance> preferenceImportances;
    Map<String, int> preferenceImportancesReverse;
    List<AttributeGroup> attributeGroups;
    try {
      dynamic inputJson = json.decode(importanceString);
      preferenceImportances = (inputJson as List<dynamic>)
          .map((dynamic item) => PreferenceImportance.fromJson(item))
          .toList();
      preferenceImportancesReverse = <String, int>{};
      int i = 0;
      for (final PreferenceImportance preferenceImportance
          in preferenceImportances) {
        preferenceImportancesReverse[preferenceImportance.id] = i++;
      }
      inputJson = json.decode(attributeGroupString);
      attributeGroups = (inputJson as List<dynamic>)
          .map((dynamic item) => AttributeGroup.fromJson(item))
          .toList();
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      return false;
    }
    _preferenceImportances = preferenceImportances;
    _preferenceImportancesReverse = preferenceImportancesReverse;
    _attributeGroups = attributeGroups;
    _languageCode = languageCode;
    _isHttps = isHttps;
    return true;
  }

  /// Returns the index of an importance.
  ///
  /// From 0: not important.
  int getImportanceIndex(final String importanceId) =>
      _preferenceImportancesReverse[importanceId] ??
      PreferenceImportance.INDEX_NOT_IMPORTANT;

  /// Returns the index of the importance of an attribute.
  ///
  /// From 0: not important.
  int getAttributeImportanceIndex(final String attributeId) =>
      getImportanceIndex(getPreferenceImportance(attributeId).id);

  /// Returns the importance of an attribute.
  PreferenceImportance getPreferenceImportance(final String attributeId) =>
      _preferenceImportances[loadImportance(attributeId)];

  /// Returns all important attributes, ordered by descending importance.
  List<String> getOrderedImportantAttributeIds() {
    final Map<int, List<String>> map = <int, List<String>>{};
    for (final AttributeGroup attributeGroup in attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        final String variable = attribute.id;
        final int importance = getAttributeImportanceIndex(variable);
        if (importance == null ||
            importance == PreferenceImportance.INDEX_NOT_IMPORTANT) {
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

  /// Returns the attribute from the localized reference.
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

  // TODO(stephanegigandet): move to Product as non-static method getAttribute(final String attributeId)
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
      if (attributeGroup.attributes == null) {
        continue;
      }
      for (final Attribute attribute in attributeGroup.attributes) {
        if (attribute.id == attributeId) {
          return attribute;
        }
        // TODO(stephanegigandet): have it fixed upstream?
        if (attribute.id == 'palm-oil-free' && attributeId == 'palm_oil_free') {
          return attribute;
        }
      }
    }
    return null;
  }
}
