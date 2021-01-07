import 'package:shared_preferences/shared_preferences.dart';

class UserThemePreference {
  static const String THEME_STATUS = 'THEMESTATUS';

  Future<void> setDarkTheme(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }
}
