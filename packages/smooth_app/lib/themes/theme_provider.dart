import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider(this._userPreferences);

  final UserPreferences _userPreferences;

  bool get darkTheme => _userPreferences.isThemeDark;

  Future<void> setDarkTheme(bool value) async {
    if (darkTheme == value) {
      return;
    }
    await _userPreferences.setThemeDark(value);
    notifyListeners();
  }

  String get colorTag => _userPreferences.themeColorTag;

  Future<void> setColorTag(final String value) async {
    if (colorTag == value) {
      return;
    }
    await _userPreferences.setThemeColorTag(value);
    notifyListeners();
  }

  MaterialColor get materialColor => darkTheme
      ? Colors.grey
      : SmoothTheme.MATERIAL_COLORS[colorTag] ??
          SmoothTheme.MATERIAL_COLORS[SmoothTheme.COLOR_TAG_BLUE]!;
}
