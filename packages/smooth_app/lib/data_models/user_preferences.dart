import 'package:flutter/material.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

class UserPreferences extends ChangeNotifier {
  UserPreferences._shared(final SharedPreferences sharedPreferences)
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static Future<UserPreferences> getUserPreferences() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return UserPreferences._shared(preferences);
  }

  static const String _TAG_PREFIX_IMPORTANCE = 'IMPORTANCE_AS_STRING';
  static const String _TAG_INIT = 'init';
  static const String _TAG_THEME_DARK = 'themeDark';
  static const String _TAG_THEME_COLOR_TAG = 'themeColorTag';
  static const String _TAG_USER_COUNTRY_CODE = 'userCountry';
  static const String _TAG_LAST_VISITED_ONBOARDING_PAGE =
      'lastVisitedOnboardingPage';
  static const String _TAG_PREFIX_FLAG = 'FLAG_PREFIX_';
  static const String _TAG_DEV_MODE = 'devMode';
  static const String _TAG_CAMERA_DECLINE = 'declined_camera_use_once';
  static const String _TAG_CRASH_REPORTS = 'crash_reports';
  static const String _TAG_ANALYTICS_REPORTS = 'analytics_reports';

  Future<void> init(final ProductPreferences productPreferences) async {
    if (_sharedPreferences.getBool(_TAG_INIT) != null) {
      return;
    }
    await productPreferences.resetImportances();
    await _sharedPreferences.setBool(_TAG_INIT, true);
  }

  String _getImportanceTag(final String variable) =>
      _TAG_PREFIX_IMPORTANCE + variable;

  Future<void> setImportance(
    final String attributeId,
    final String importanceId,
  ) async =>
      _sharedPreferences.setString(
          _getImportanceTag(attributeId), importanceId);

  String getImportance(final String attributeId) =>
      _sharedPreferences.getString(_getImportanceTag(attributeId)) ??
      PreferenceImportance.ID_NOT_IMPORTANT;

  Future<void> setThemeDark(final bool state) async =>
      _sharedPreferences.setBool(_TAG_THEME_DARK, state);

  bool get isThemeDark => _sharedPreferences.getBool(_TAG_THEME_DARK) ?? false;

  Future<void> setCrashReports(final bool state) async =>
      _sharedPreferences.setBool(_TAG_CRASH_REPORTS, state);

  bool get crashReports =>
      _sharedPreferences.getBool(_TAG_CRASH_REPORTS) ?? true;

  Future<void> setAnalyticsReports(final bool state) async =>
      _sharedPreferences.setBool(_TAG_ANALYTICS_REPORTS, state);

  bool get analyticsReports =>
      _sharedPreferences.getBool(_TAG_ANALYTICS_REPORTS) ?? true;

  Future<void> setThemeColorTag(final String colorTag) async =>
      _sharedPreferences.setString(_TAG_THEME_COLOR_TAG, colorTag);

  String get themeColorTag =>
      _sharedPreferences.getString(_TAG_THEME_COLOR_TAG) ?? 'COLOR_TAG_BLUE';

  Future<void> setUserCountry(final String countryCode) async =>
      _sharedPreferences.setString(_TAG_USER_COUNTRY_CODE, countryCode);

  String? get userCountryCode =>
      _sharedPreferences.getString(_TAG_USER_COUNTRY_CODE);

  Future<void> setLastVisitedOnboardingPage(final OnboardingPage page) async =>
      _sharedPreferences.setInt(_TAG_LAST_VISITED_ONBOARDING_PAGE, page.index);

  OnboardingPage get lastVisitedOnboardingPage {
    final int? pageIndex =
        _sharedPreferences.getInt(_TAG_LAST_VISITED_ONBOARDING_PAGE);
    return pageIndex == null
        ? OnboardingPage.NOT_STARTED
        : OnboardingPage.values[pageIndex];
  }

  Future<void> setCameraDecline(final bool declined) async {
    _sharedPreferences.setBool(_TAG_CAMERA_DECLINE, declined);
  }

  bool get cameraDeclinedOnce =>
      _sharedPreferences.getBool(_TAG_CAMERA_DECLINE) ?? false;

  String _getFlagTag(final String key) => _TAG_PREFIX_FLAG + key;

  Future<void> setFlag(
    final String key,
    final bool? value,
  ) async =>
      value == null
          ? await _sharedPreferences.remove(_getFlagTag(key))
          : await _sharedPreferences.setBool(_getFlagTag(key), value);

  bool? getFlag(final String key) =>
      _sharedPreferences.getBool(_getFlagTag(key));

  Future<void> setDevMode(final int value) async =>
      _sharedPreferences.setInt(_TAG_DEV_MODE, value);

  int get devMode => _sharedPreferences.getInt(_TAG_DEV_MODE) ?? 0;

  Future<void> setDevModeIndex(final String tag, final int index) async =>
      _sharedPreferences.setInt(tag, index);

  int? getDevModeIndex(final String tag) => _sharedPreferences.getInt(tag);

  Future<void> setDevModeString(final String tag, final String value) async =>
      _sharedPreferences.setString(tag, value);

  String? getDevModeString(final String tag) =>
      _sharedPreferences.getString(tag);
}
