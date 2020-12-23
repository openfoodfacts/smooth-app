import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_app/database/user_database.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class UserPreferencesModel extends ChangeNotifier {
  UserPreferencesModel(final BuildContext context)
      : _userDatabase = UserDatabase() {
    _loadData(context);
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

  Future<bool> _loadData(final BuildContext context) async {
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

  String getStringValue(final String variable) =>
      _preferenceValues[_userPreferences.getValue(variable)].id;

  int getScoreIndex(final String variable) =>
      _preferenceValuesReverse[getStringValue(variable)] ??
      UserPreferences.INDEX_NOT_IMPORTANT;

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
    _preferenceValues = (json as List)
        .map((dynamic item) => PreferencesValue.fromJson(item))
        .toList();
    _preferenceValuesReverse = {};
    int i = 0;
    for (final PreferencesValue preferencesValue in _preferenceValues) {
      _preferenceValuesReverse[preferencesValue.id] = i++;
    }
  }

  void _loadVariables(dynamic json) {
    _preferenceVariableGroups = (json as List)
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
  PreferencesValue({this.id, this.name});

  factory PreferencesValue.fromJson(dynamic json) => PreferencesValue(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  final String id;
  final String name;

  static const String NOT_IMPORTANT = 'not_important';
  static const String IMPORTANT = 'important';
  static const String VERY_IMPORTANT = 'very_important';
  static const String MANDATORY = 'mandatory';

  @override
  String toString() => 'PreferencesValue(id: $id, name: $name)';
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

  static const String VEGAN = 'vegan';
  static const String VEGETARIAN = 'vegetarian';
  static const String GLUTEN_FREE = 'allergens_no_gluten';
  static const String ORGANIC_LABELS = 'labels_organic';
  static const String FAIR_TRADE_LABELS = 'labels_fair_trade';
  static const String PALM_FREE_LABELS = 'palm_oil_free';
  static const String ADDITIVES = 'additives';
  static const String NOVA_GROUP = 'nova';
  static const String NUTRI_SCORE = 'nutriscore';

  static List<String> getMandatoryVariables() => <String>[
        VEGAN,
        VEGETARIAN,
        //GLUTEN_FREE,
      ];

  static List<String> getAccountableVariables() => <String>[
        ORGANIC_LABELS,
        FAIR_TRADE_LABELS,
        PALM_FREE_LABELS,
        ADDITIVES,
        NOVA_GROUP,
        NUTRI_SCORE,
      ];

  @override
  String toString() =>
      'PreferencesVariable(' +
      'id: $id' +
      ', name: $name' +
      ', icon_url: $iconUrl' +
      ', default: $defaultF' +
      ', settingNote: $settingNote' +
      ', settingName: $settingName' +
      ', description: $description' +
      ', description_short: $descriptionShort' +
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
    final attributes = json['attributes'] as List;
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
  String toString() =>
      'PreferencesVariableGroup(' +
      'id: $id, name: $name, warning: $warning, list: $list' +
      ')';
}
