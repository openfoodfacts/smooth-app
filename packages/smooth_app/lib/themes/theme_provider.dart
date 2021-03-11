// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:smooth_app/temp/user_preferences.dart';

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
}
