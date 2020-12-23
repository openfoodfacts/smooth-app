// Note to myself : this needs to be transferred to the openfoodfacts-dart plugin when ready

import 'package:smooth_app/data_models/user_preferences_model.dart';

class UserPreferences {
  UserPreferences();

  UserPreferences.filled(Map<String, dynamic> data) {
    loadJson(data);
  }

  static const int INDEX_NOT_IMPORTANT = 0;

  final Map<String, int> _currentValues = <String, int>{};

  void setValue(String variable, int value) => _currentValues[variable] = value;

  int getValue(String variable) =>
      _currentValues[variable] ?? INDEX_NOT_IMPORTANT;

  List<String> getActiveVariables() {
    final List<String> result = <String>[];
    for (final String variable in UserPreferencesModel.getVariables()) {
      if (getValue(variable) != INDEX_NOT_IMPORTANT) {
        result.add(variable);
      }
    }
    return result;
  }

  void loadJson(Map<String, dynamic> data) {
    for (final String variable in UserPreferencesModel.getVariables()) {
      if (data[variable] is! int) {
        setValue(variable, INDEX_NOT_IMPORTANT);
      } else {
        setValue(variable, data[variable] as int ?? INDEX_NOT_IMPORTANT);
      }
    }
  }

  Map<String, int> toJson() {
    final Map<String, int> result = <String, int>{};

    for (final String variable in UserPreferencesModel.getVariables()) {
      result[variable] = getValue(variable);
    }

    return result;
  }
}
