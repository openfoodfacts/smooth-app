// Note to myself : this needs to be transferred to the openfoodfacts-dart plugin when ready

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/temp/attribute_group.dart';

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

  String _getImportanceTag(final String variable) =>
      _TAG_PREFIX_IMPORTANCE + variable;

  Future<void> setImportance(String variable, int value) async {
    _sharedPreferences.setInt(_getImportanceTag(variable), value);
    notifyListeners();
  }

  int getImportance(String variable) =>
      _sharedPreferences.getInt(_getImportanceTag(variable)) ??
      INDEX_NOT_IMPORTANT;

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
