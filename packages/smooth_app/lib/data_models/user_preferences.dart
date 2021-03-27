// Note to myself : this needs to be transferred to the openfoodfacts-dart plugin when ready

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:smooth_app/data_models/pantry.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';

class UserPreferences extends ChangeNotifier {
  UserPreferences._shared(final SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  SharedPreferences _sharedPreferences;

  static Future<UserPreferences> getUserPreferences() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return UserPreferences._shared(preferences);
  }

  static const String _TAG_PREFIX_IMPORTANCE = 'IMPORTANCE_AS_STRING';
  static const String _TAG_PANTRY_REPOSITORY = 'pantry_repository';
  static const String _TAG_SHOPPING_REPOSITORY = 'shopping_repository';
  static const String _TAG_VISIBLE_GROUPS = 'visible_groups';
  static const String _TAG_INIT = 'init';
  static const String _TAG_PRODUCT_LIST_COPY = 'productListCopy';
  static const String _TAG_THEME_DARK = 'themeDark';
  static const String _TAG_THEME_COLOR_TAG = 'themeColorTag';

  static const Map<PantryType, String> _PANTRY_TYPE_TO_TAG =
      <PantryType, String>{
    PantryType.PANTRY: _TAG_PANTRY_REPOSITORY,
    PantryType.SHOPPING: _TAG_SHOPPING_REPOSITORY,
  };

  Future<void> init(final ProductPreferences productPreferences) async {
    final bool alreadyDone = _sharedPreferences.getBool(_TAG_INIT);
    if (alreadyDone != null) {
      return;
    }
    await productPreferences.resetImportances();
    await _sharedPreferences.setBool(_TAG_INIT, true);
  }

  String _getImportanceTag(final String variable) =>
      _TAG_PREFIX_IMPORTANCE + variable;

  Future<void> setImportance(
    final String attributeId,
    final String importanceId,
  ) async =>
      await _sharedPreferences.setString(
          _getImportanceTag(attributeId), importanceId);

  String getImportance(final String attributeId) =>
      _sharedPreferences.getString(_getImportanceTag(attributeId)) ??
      PreferenceImportance.ID_NOT_IMPORTANT;

  Future<void> resetImportances(
    final ProductPreferences productPreferences,
  ) async {
    await _sharedPreferences.remove(_TAG_VISIBLE_GROUPS);
    await productPreferences.resetImportances();
  }

  bool isAttributeGroupVisible(final AttributeGroup group) {
    final List<String> visibleList =
        _sharedPreferences.getStringList(_TAG_VISIBLE_GROUPS);
    return visibleList != null && visibleList.contains(group.id);
  }

  Future<void> setAttributeGroupVisibility(
      final AttributeGroup group, final bool visible) async {
    final List<String> visibleList =
        _sharedPreferences.getStringList(_TAG_VISIBLE_GROUPS) ?? <String>[];
    final String tag = group.id;
    if (visibleList.contains(tag)) {
      if (visible) {
        return;
      }
      visibleList.remove(tag);
    } else {
      if (!visible) {
        return;
      }
      visibleList.add(tag);
    }
    await _sharedPreferences.setStringList(_TAG_VISIBLE_GROUPS, visibleList);
    notifyListeners();
  }

  String getProductListCopy() =>
      _sharedPreferences.getString(_TAG_PRODUCT_LIST_COPY);

  Future<void> setProductListCopy(final String productListLousyKey) async =>
      await _sharedPreferences.setString(
          _TAG_PRODUCT_LIST_COPY, productListLousyKey);

  Future<void> setPantryRepository(
    final List<String> encodedJsons,
    final PantryType pantryType,
  ) async {
    await _sharedPreferences.setStringList(
      _PANTRY_TYPE_TO_TAG[pantryType],
      encodedJsons,
    );
    notifyListeners();
  }

  List<String> getPantryRepository(final PantryType pantryType) =>
      _sharedPreferences.getStringList(_PANTRY_TYPE_TO_TAG[pantryType]) ??
      <String>[];

  Future<void> setThemeDark(final bool state) async =>
      await _sharedPreferences.setBool(_TAG_THEME_DARK, state);

  bool get isThemeDark => _sharedPreferences.getBool(_TAG_THEME_DARK) ?? false;

  Future<void> setThemeColorTag(final String colorTag) async =>
      await _sharedPreferences.setString(_TAG_THEME_COLOR_TAG, colorTag);

  String get themeColorTag =>
      _sharedPreferences.getString(_TAG_THEME_COLOR_TAG);
}
