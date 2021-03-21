import 'package:flutter/material.dart';
import 'package:smooth_app/temp/product_preferences_selection.dart';

import 'package:flutter/cupertino.dart';
import 'package:smooth_app/temp/product_preferences_manager.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_app/temp/attribute_group_referential.dart';
import 'package:smooth_app/temp/preference_importance_referential.dart';
import 'package:smooth_app/temp/product_preferences_referential.dart';

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
    final String importanceString =
        await assetBundle.loadString(importanceAssetPath);
    final String attributeGroupString =
        await assetBundle.loadString(attributeGroupAssetPath);
    final ProductPreferencesReferential myProductPreferencesRepository =
        ProductPreferencesReferential.loadFromJSONStrings(
            importanceString, attributeGroupString);
    productPreferencesRepository = myProductPreferencesRepository;
    _isNetwork = false;
    _languageCode = languageCode;
  }

  /// Loads the references of importance and attribute groups from urls.
  ///
  /// May throw an exception.
  Future<void> loadReferenceFromNetwork(String languageCode) async {
    final String importanceUrl =
        PreferenceImportanceReferential.getUrl(languageCode);
    final String attributeGroupUrl =
        AttributeGroupReferential.getUrl(languageCode);
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
    final ProductPreferencesReferential myProductPreferencesRepository =
        ProductPreferencesReferential.loadFromJSONStrings(
            importanceString, attributeGroupString);
    productPreferencesRepository = myProductPreferencesRepository;
    _isNetwork = true;
    _languageCode = languageCode;
  }
}
