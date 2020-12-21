import 'package:flutter/cupertino.dart';
import 'package:smooth_app/data_models/food_preferences_model.dart';
import 'package:smooth_app/database/user_database.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class UserPreferencesModel extends ChangeNotifier {
  UserPreferencesModel() {
    userDatabase = UserDatabase();
    _loadData();
  }

  Future<bool> _loadData() async {
    try {
      userPreferences = await userDatabase.getUserPreferences();
      dataLoaded = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      dataLoaded = false;
      return false;
    }
  }

  UserDatabase userDatabase;
  UserPreferences userPreferences;
  bool dataLoaded = false;

  UserPreferencesVariableValue getVariable(UserPreferencesVariable variable) {
    return userPreferences.getVariable(variable);
  }

  void setVariable(UserPreferencesVariable variable, int value) {
    if (dataLoaded) {
      userPreferences.setVariable(
          variable, UserPreferencesVariableValueExtention.fromInt(value));
      notifyListeners();
    }
  }

  void saveUserPreferences() {
    userDatabase.saveUserPreferences(userPreferences);
  }
}
