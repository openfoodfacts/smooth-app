import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_app/database/user_database.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class UserPreferencesModel extends ChangeNotifier {
  UserPreferencesModel() : _userDatabase = UserDatabase();

  UserPreferencesModel.load(final BuildContext context)
      : _userDatabase = UserDatabase() {
    loadData(context);
  }

  static final List<String> _preferencesVariables = <String>[];
  static final Map<String, String> _preferencesVariableLabels =
      <String, String>{};
  static List<PreferencesValue> _preferenceValues;
  static Map<String, int> _preferenceValuesReverse;
  static List<PreferencesVariableGroup> _preferenceVariableGroups;

  final UserDatabase _userDatabase;
  UserPreferences _userPreferences;
  bool _dataLoaded = false;

  bool get dataLoaded => _dataLoaded;
  UserPreferences get userPreferences => _userPreferences;

  Future<bool> loadData(final BuildContext context) async {
    try {
      final String valueString = await DefaultAssetBundle.of(context)
          .loadString('assets/metadata/init_preferences.json');
      final dynamic valueJson =
          json.decode(valueString).cast<Map<String, dynamic>>();
      _loadValues(valueJson);
      final String variableString = await DefaultAssetBundle.of(context)
          .loadString('assets/metadata/init_attribute_groups.json');
      final dynamic variableJson = json.decode(variableString);
      _loadVariables(variableJson);
      _userPreferences = await _userDatabase.getUserPreferences();
      _dataLoaded = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      _dataLoaded = false;
      return false;
    }
  }

  int getValueIndex(final String variable) =>
      _preferenceValuesReverse[getPreferencesValue(variable).id] ??
      UserPreferences.INDEX_NOT_IMPORTANT;

  PreferencesValue getPreferencesValue(final String variable) =>
      _preferenceValues[_userPreferences.getValue(variable)];

  void setValue(final String variable, final int value) {
    if (_dataLoaded) {
      _userPreferences.setValue(variable, value);
      notifyListeners();
    }
  }

  void saveUserPreferences() =>
      _userDatabase.saveUserPreferences(_userPreferences);

  static String getVariableName(final String variable) =>
      _preferencesVariableLabels[variable];

  String getValueName(final String variable) =>
      _preferenceValues[_userPreferences.getValue(variable)].name;

  static List<String> getVariables() => _preferencesVariables;

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

  void _loadVariables(dynamic json) {
    _preferenceVariableGroups = (json as List<dynamic>)
        .map((dynamic item) => PreferencesVariableGroup.fromJson(item))
        .toList();
    _preferencesVariables.clear();
    _preferencesVariableLabels.clear();
    for (final PreferencesVariableGroup group in _preferenceVariableGroups) {
      for (final PreferencesVariable variable in group.list) {
        _preferencesVariables.add(variable.id);
        _preferencesVariableLabels[variable.id] = variable.name;
      }
    }
  }
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

class PreferencesVariable {
  PreferencesVariable({
    this.id,
    this.name,
    this.iconUrl,
    this.defaultF,
    this.settingNote,
    this.settingName,
    this.description,
    this.descriptionShort,
  });

  factory PreferencesVariable.fromJson(dynamic json) => PreferencesVariable(
        id: json['id'] as String,
        name: json['name'] as String,
        iconUrl: json['icon_url'] as String,
        defaultF: json['default'] as String,
        settingNote: json['setting_note'] as String,
        settingName: json['setting_name'] as String,
        description: json['description'] as String,
        descriptionShort: json['description_short'] as String,
      );

  final String id;
  final String name;
  final String iconUrl;
  final String defaultF;
  final String settingNote;
  final String settingName;
  final String description;
  final String descriptionShort;

  @override
  String toString() => 'PreferencesVariable('
      'id: $id'
      ', name: $name'
      ', icon_url: $iconUrl'
      ', default: $defaultF'
      ', settingNote: $settingNote'
      ', settingName: $settingName'
      ', description: $description'
      ', description_short: $descriptionShort'
      ')';
}

class PreferencesVariableGroup {
  PreferencesVariableGroup({
    this.id,
    this.name,
    this.warning,
    this.list,
  });

  factory PreferencesVariableGroup.fromJson(dynamic json) {

    final  List<dynamic> attributes = json['attributes'] as List<dynamic>;
    final List<PreferencesVariable> variables = attributes
        .map((dynamic item) => PreferencesVariable.fromJson(item))
        .toList();
    return PreferencesVariableGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      warning: json['warning'] as String,
      list: variables,
    );
  }

  final String id;
  final String name;
  final String warning;
  final List<PreferencesVariable> list;

  @override
  String toString() => 'PreferencesVariableGroup('
      'id: $id, name: $name, warning: $warning, list: $list'
      ')';
}
