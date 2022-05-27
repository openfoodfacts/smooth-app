import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

const String THEME_SYSTEM_DEFAULT = 'System Default';
const String THEME_LIGHT = 'Light';
const String THEME_DARK = 'Dark';

class ThemeProvider with ChangeNotifier {
  ThemeProvider(this._userPreferences);

  final UserPreferences _userPreferences;

  String get currentTheme => _userPreferences.currentTheme;

  ThemeMode get currentThemeMode {
    if (_userPreferences.currentTheme == THEME_SYSTEM_DEFAULT) {
      return ThemeMode.system;
    } else if (_userPreferences.currentTheme == THEME_LIGHT) {
      return ThemeMode.light;
    } else {
      return ThemeMode.dark;
    }
  }

  Future<void> setTheme(String value) async {
    assert(value != THEME_LIGHT || value != THEME_DARK);
    await _userPreferences.setTheme(value);
    notifyListeners();
  }

  bool isDarkMode(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
}
