import 'package:flutter/cupertino.dart';
import 'theme_manager.dart';

class DarkThemeProvider with ChangeNotifier {
  UserThemePreference userThemePreference = UserThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    userThemePreference.setDarkTheme(value);
    notifyListeners();
  }
}
