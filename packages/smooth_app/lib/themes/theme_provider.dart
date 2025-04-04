import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';

const String THEME_SYSTEM_DEFAULT = 'System Default';
const String THEME_LIGHT = 'Light';
const String THEME_DARK = 'Dark';
const String THEME_AMOLED = 'AMOLED';

class ThemeProvider with ChangeNotifier {
  ThemeProvider(this._userPreferences)
      : _theme = _userPreferences.currentTheme {
    _userPreferences.addListener(_onPreferencesChanged);
  }

  final UserPreferences _userPreferences;

  // The onboarding needs the light mode.
  bool _forceLight = false;

  // Local cache for [_userPreferences.currentTheme]
  String _theme;

  void _onPreferencesChanged() {
    final String newTheme = _userPreferences.currentTheme;
    if (newTheme != _theme) {
      _theme = newTheme;
      notifyListeners();
    }
  }

  String get currentTheme => _forceLight ? THEME_LIGHT : _theme;

  void setOnboardingComplete(final bool onboardingComplete) {
    _forceLight = !onboardingComplete;
  }

  bool get isLightTheme => _forceLight || currentTheme == THEME_LIGHT;

  bool get isDarkTheme => !_forceLight && currentTheme == THEME_DARK;

  bool get isAmoledTheme => !_forceLight && currentTheme == THEME_AMOLED;

  void finishOnboarding() {
    setOnboardingComplete(true);

    WidgetsBinding.instance
      ..addPostFrameCallback((_) => notifyListeners())
      ..ensureVisualUpdate();
  }

  ThemeMode get currentThemeMode {
    switch (currentTheme) {
      case THEME_SYSTEM_DEFAULT:
        return ThemeMode.system;
      case THEME_LIGHT:
        return ThemeMode.light;
      case THEME_AMOLED:
        return ThemeMode.dark;
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> setTheme(String value) async {
    assert(
        value != THEME_LIGHT || value != THEME_DARK || value != THEME_AMOLED);
    await _userPreferences.setTheme(value);
    notifyListeners();
  }

  bool isDarkMode(BuildContext context) {
    if (currentTheme == THEME_SYSTEM_DEFAULT) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return <String>[THEME_DARK, THEME_AMOLED].contains(currentTheme);
  }

  @override
  void dispose() {
    _userPreferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }
}

extension ThemeProviderExtension on BuildContext {
  bool lightTheme({bool listen = true}) => !darkTheme(listen: listen);

  bool darkTheme({bool listen = true}) =>
      Provider.of<ThemeProvider>(this, listen: listen).isDarkMode(this);
}
