import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/personalized_search/available_attribute_groups.dart';
import 'package:openfoodfacts/personalized_search/available_preference_importances.dart';
import 'package:openfoodfacts/personalized_search/available_product_preferences.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_manager.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class ProductPreferences extends ProductPreferencesManager with ChangeNotifier {
  ProductPreferences(
    final ProductPreferencesSelection productPreferencesSelection,
  ) : super(productPreferencesSelection);

  /// 2-letter language code of the latest reference load.
  String _languageCode;

  /// "was it a network load" bool of the latest reference load.
  bool _isNetwork;

  String get languageCode => _languageCode;
  bool get isNetwork => _isNetwork;

  @override
  void notifyListeners() => super.notifyListeners();

  static const String _DEFAULT_LANGUAGE_CODE = 'en';
  static String _getImportanceAssetPath(final String languageCode) =>
      'assets/metadata/init_preferences_$languageCode.json';
  static String _getAttributeAssetPath(final String languageCode) =>
      'assets/metadata/init_attribute_groups_$languageCode.json';

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
      return false;
    }
    final String preferenceImportancesString = response.body;
    response = await http.get(Uri.parse(attributeGroupUrl));
    if (response.statusCode != 200) {
      return false;
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
    await setImportance(
      Attribute.ATTRIBUTE_NUTRISCORE,
      PreferenceImportance.ID_VERY_IMPORTANT,
      notifyListeners: false,
    );
    await setImportance(
      Attribute.ATTRIBUTE_NOVA,
      PreferenceImportance.ID_IMPORTANT,
      notifyListeners: false,
    );
    await setImportance(
      Attribute.ATTRIBUTE_ECOSCORE,
      PreferenceImportance.ID_IMPORTANT,
      notifyListeners: false,
    );
    notify();
  }
}
