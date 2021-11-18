import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/personalized_search/available_attribute_groups.dart';
import 'package:openfoodfacts/personalized_search/available_preference_importances.dart';
import 'package:openfoodfacts/personalized_search/available_product_preferences.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_manager.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';

class ProductPreferences extends ProductPreferencesManager with ChangeNotifier {
  ProductPreferences(
    final ProductPreferencesSelection productPreferencesSelection,
  ) : super(productPreferencesSelection);

  /// 2-letter language code of the latest reference load.
  late String _languageCode;

  /// "was it a network load" bool of the latest reference load.
  late bool _isNetwork;

  String get languageCode => _languageCode;
  bool get isNetwork => _isNetwork;

  /// Notify listeners
  /// Comments added only in order to avoid a "warning"
  /// For the record, we need to override the method
  /// because the parent's is protected
  @override
  void notifyListeners() => super.notifyListeners();

  static const String _DEFAULT_LANGUAGE_CODE = 'en';
  static String _getImportanceAssetPath(final String languageCode) =>
      'assets/metadata/init_preferences_$languageCode.json';
  static String _getAttributeAssetPath(final String languageCode) =>
      'assets/metadata/init_attribute_groups_$languageCode.json';

  static const List<String> _DEFAULT_ATTRIBUTES = <String>[
    Attribute.ATTRIBUTE_NUTRISCORE,
    Attribute.ATTRIBUTE_ECOSCORE,
    Attribute.ATTRIBUTE_NOVA,
    Attribute.ATTRIBUTE_VEGETARIAN,
    Attribute.ATTRIBUTE_VEGAN,
    Attribute.ATTRIBUTE_PALM_OIL_FREE,
    Attribute.ATTRIBUTE_LOW_SALT,
    Attribute.ATTRIBUTE_LOW_SUGARS,
    Attribute.ATTRIBUTE_LOW_FAT,
    Attribute.ATTRIBUTE_LOW_SATURATED_FAT,
    Attribute.ATTRIBUTE_LABELS_ORGANIC,
    Attribute.ATTRIBUTE_LABELS_FAIR_TRADE,
    Attribute.ATTRIBUTE_FOREST_FOOTPRINT,
  ];

  /// Loads the references of importance and attribute groups from assets.
  ///
  /// May throw an exception.
  Future<void> loadReferenceFromAssets(
    final AssetBundle assetBundle, {
    final String languageCode = _DEFAULT_LANGUAGE_CODE,
  }) async {
    final String importanceAssetPath = _getImportanceAssetPath(languageCode);
    final String attributeGroupAssetPath = _getAttributeAssetPath(languageCode);
    final String preferenceImportancesString =
        await assetBundle.loadString(importanceAssetPath);
    final String attributeGroupString =
        await assetBundle.loadString(attributeGroupAssetPath);
    final AvailableProductPreferences myAvailableProductPreferences =
        AvailableProductPreferences.loadFromJSONStrings(
      preferenceImportancesString: preferenceImportancesString,
      attributeGroupsString: attributeGroupString,
    );
    availableProductPreferences = myAvailableProductPreferences;
    _isNetwork = false;
    _languageCode = languageCode;
  }

  /// Loads the references of importance and attribute groups from urls.
  ///
  /// May throw an exception.
  Future<void> loadReferenceFromNetwork(String languageCode) async {
    final String importanceUrl =
        AvailablePreferenceImportances.getUrl(languageCode);
    final String attributeGroupUrl =
        AvailableAttributeGroups.getUrl(languageCode);
    http.Response response;
    response = await http.get(Uri.parse(importanceUrl));
    if (response.statusCode != 200) {
      return;
    }
    final String preferenceImportancesString = response.body;
    response = await http.get(Uri.parse(attributeGroupUrl));
    if (response.statusCode != 200) {
      return;
    }
    final String attributeGroupsString = response.body;
    final AvailableProductPreferences myAvailableProductPreferences =
        AvailableProductPreferences.loadFromJSONStrings(
      preferenceImportancesString: preferenceImportancesString,
      attributeGroupsString: attributeGroupsString,
    );
    availableProductPreferences = myAvailableProductPreferences;
    _isNetwork = true;
    _languageCode = languageCode;
  }

  Future<void> resetImportances() async {
    await clearImportances(notifyListeners: false);
    // Execute all network calls in parallel.
    await Future.wait(
      _DEFAULT_ATTRIBUTES.map(
        (String attributeId) => setImportance(
          attributeId,
          PreferenceImportance.ID_IMPORTANT,
          notifyListeners: false,
        ),
      ),
    );
    notify();
  }

  AttributeGroup getAttributeGroup(final String attributeId) {
    for (final AttributeGroup attributeGroup in attributeGroups!) {
      for (final Attribute item in attributeGroup.attributes!) {
        if (item.id == attributeId) {
          return attributeGroup;
        }
      }
    }
    throw Exception('unknown attribute group for $attributeId');
  }
}
