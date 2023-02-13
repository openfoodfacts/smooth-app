import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

class ColorProvider with ChangeNotifier {
  ColorProvider(this._userPreferences);

  final UserPreferences _userPreferences;

  String get currentColor => _userPreferences.currentColor;

  Future<void> setColor(String value) async {
    await _userPreferences.setColorScheme(value);
    notifyListeners();
  }
}
