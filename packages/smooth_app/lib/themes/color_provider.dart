import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';

/// Keep track of Color Change in AppSetting
/// Only available for AMOLED as of Now.
class ColorProvider with ChangeNotifier {
  ColorProvider(this._userPreferences);

  final UserPreferences _userPreferences;

  /// Get current Color
  String get currentColor => _userPreferences.currentColor;

  /// Set Color
  Future<void> setColor(String value) async {
    await _userPreferences.setColorScheme(value);
    notifyListeners();
  }
}
