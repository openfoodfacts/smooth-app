import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

const String THEME_SYSTEM_DEFAULT = 'System Default';
const String THEME_LIGHT = 'Light';
const String THEME_DARK = 'Dark';

class ThemeProvider with ChangeNotifier {
  ThemeProvider(this._userPreferences);

  final UserPreferences _userPreferences;
  // The onboarding needs the light mode.
  bool _forceLight = false;

  String get currentTheme =>
      _forceLight ? THEME_LIGHT : _userPreferences.currentTheme;

  void setOnboardingComplete(final bool onboardingComplete) {
    _forceLight = !onboardingComplete;
  }

  void finishOnboarding() {
    setOnboardingComplete(true);
    notifyListeners();
  }

  ThemeMode get currentThemeMode {
    switch (currentTheme) {
      case THEME_SYSTEM_DEFAULT:
        return ThemeMode.system;
      case THEME_LIGHT:
        return ThemeMode.light;
      default:
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
