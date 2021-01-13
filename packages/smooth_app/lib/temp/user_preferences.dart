// Note to myself : this needs to be transferred to the openfoodfacts-dart plugin when ready

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class UserPreferences extends ChangeNotifier {
  UserPreferences._shared(final SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  SharedPreferences _sharedPreferences;

  static Future<UserPreferences> getUserPreferences() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return UserPreferences._shared(preferences);
  }

  static const int INDEX_NOT_IMPORTANT = 0;

  static const String _TAG_PREFIX_IMPORTANCE = 'IMPORTANCE';
  static const String _TAG_HIDDEN_GROUPS = 'hidden_groups';
  static const String _TAG_USE_ML_KIT = 'useMlKit';
  static const String _TAG_INIT = 'init';

  Future<void> init(final UserPreferencesModel userPreferencesModel) async {
    final bool alreadyDone = _sharedPreferences.getBool(_TAG_INIT);
    if (alreadyDone != null) {
      return;
    }
    await resetImportances(userPreferencesModel);
    await _sharedPreferences.setBool(_TAG_INIT, true);
  }

  String _getImportanceTag(final String variable) =>
      _TAG_PREFIX_IMPORTANCE + variable;

  Future<void> setImportance(String variable, int value) async =>
      _setImportance(variable, value, notify: true);

  Future<void> _setImportance(
    String variable,
    int value, {
    bool notify = true,
  }) async {
    await _sharedPreferences.setInt(_getImportanceTag(variable), value);
    if (notify) {
      notifyListeners();
    }
  }

  int getImportance(String variable) =>
      _sharedPreferences.getInt(_getImportanceTag(variable)) ??
      INDEX_NOT_IMPORTANT;

  Future<void> resetImportances(
      final UserPreferencesModel userPreferencesModel) async {
    for (final AttributeGroup attributeGroup
        in userPreferencesModel.attributeGroups) {
      for (final Attribute attribute in attributeGroup.attributes) {
        await _setImportance(attribute.id, INDEX_NOT_IMPORTANT, notify: false);
      }
    }
    int valueIndex;
    valueIndex = userPreferencesModel.getValueIndex('very_important');
    if (valueIndex != null) {
      await _setImportance('nutriscore', valueIndex, notify: false);
    }
    valueIndex = userPreferencesModel.getValueIndex('important');
    if (valueIndex != null) {
      await _setImportance('nova', valueIndex, notify: false);
      await _setImportance('ecoscore', valueIndex, notify: false);
    }
    _sharedPreferences.setStringList(_TAG_HIDDEN_GROUPS, null);
    notifyListeners();
  }

  bool isAttributeGroupVisible(final AttributeGroup group) {
    final List<String> hiddenList =
        _sharedPreferences.getStringList(_TAG_HIDDEN_GROUPS);
    return hiddenList == null || !hiddenList.contains(group.id);
  }

  Future<void> setAttributeGroupVisibility(
      final AttributeGroup group, final bool visible) async {
    List<String> hiddenList =
        _sharedPreferences.getStringList(_TAG_HIDDEN_GROUPS);
    final String tag = group.id;
    if (hiddenList != null && hiddenList.contains(tag)) {
      if (!visible) {
        return;
      }
      hiddenList.remove(tag);
    } else {
      if (visible) {
        return;
      }
      hiddenList ??= <String>[];
      hiddenList.add(tag);
    }
    await _sharedPreferences.setStringList(_TAG_HIDDEN_GROUPS, hiddenList);
    notifyListeners();
  }

  Future<void> setMlKitState(final bool state) async {
    await _sharedPreferences.setBool(_TAG_USE_ML_KIT, state);
    notifyListeners();
  }

  bool getMlKitState() => _sharedPreferences.getBool(_TAG_USE_ML_KIT) ?? false;
}
