import 'package:flutter/material.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';

class UserPreferences extends ChangeNotifier {
  UserPreferences._shared(final SharedPreferences sharedPreferences)
      : _sharedPreferences = sharedPreferences;

  /// Singleton
  static UserPreferences? _instance;
  final SharedPreferences _sharedPreferences;

  static Future<UserPreferences> getUserPreferences() async {
    if (_instance == null) {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      _instance = UserPreferences._shared(preferences);
    }

    return _instance!;
  }

  static const String _TAG_PREFIX_IMPORTANCE = 'IMPORTANCE_AS_STRING';
  static const String _TAG_INIT = 'init';
  static const String _TAG_CURRENT_THEME_MODE = 'currentThemeMode';
  static const String _TAG_USER_COUNTRY_CODE = 'userCountry';
  static const String _TAG_LAST_VISITED_ONBOARDING_PAGE =
      'lastVisitedOnboardingPage';
  static const String _TAG_PREFIX_FLAG = 'FLAG_PREFIX_';
  static const String _TAG_DEV_MODE = 'devMode';
  static const String _TAG_CRASH_REPORTS = 'crash_reports';
  static const String _TAG_EXCLUDED_ATTRIBUTE_IDS = 'excluded_attributes';

  /// Camera preferences
  // Detect if a first successful scan was achieved (condition to show the
  // tagline)
  static const String _TAG_IS_FIRST_SCAN = 'is_first_scan';

  // Use the flash/torch with the camera
  static const String _TAG_USE_FLASH_WITH_CAMERA = 'enable_flash_with_camera';

  // Alternative mode for the camera (file based implementation on Android)
  static const String _TAG_CAMERA_USE_ALTERNATIVE_MODE =
      'camera_alternative_mode';

  // Play sound when decoding a barcode
  static const String _TAG_PLAY_CAMERA_SCAN_SOUND = 'camera_scan_sound';

  /// Vibrations / haptic feedback
  static const String _TAG_HAPTIC_FEEDBACK_IN_APP = 'haptic_feedback_enabled';

  /// Attribute group that is not collapsed
  static const String _TAG_ACTIVE_ATTRIBUTE_GROUP = 'activeAttributeGroup';

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
  ) async {
    await _sharedPreferences.setString(
        _getImportanceTag(attributeId), importanceId);
    notifyListeners();
  }

  String getImportance(final String attributeId) =>
      _sharedPreferences.getString(_getImportanceTag(attributeId)) ??
      PreferenceImportance.ID_NOT_IMPORTANT;

  Future<void> setTheme(final String theme) async {
    await _sharedPreferences.setString(_TAG_CURRENT_THEME_MODE, theme);
    notifyListeners();
  }

  Future<void> setCrashReports(final bool state) async {
    await _sharedPreferences.setBool(_TAG_CRASH_REPORTS, state);
    notifyListeners();
  }

  bool get crashReports =>
      _sharedPreferences.getBool(_TAG_CRASH_REPORTS) ?? true;

  String get currentTheme =>
      _sharedPreferences.getString(_TAG_CURRENT_THEME_MODE) ?? 'System Default';

  Future<void> setUserCountry(final String countryCode) async {
    await _sharedPreferences.setString(_TAG_USER_COUNTRY_CODE, countryCode);
    notifyListeners();
  }

  String? get userCountryCode =>
      _sharedPreferences.getString(_TAG_USER_COUNTRY_CODE);

  Future<void> setLastVisitedOnboardingPage(final OnboardingPage page) async {
    await _sharedPreferences.setInt(
        _TAG_LAST_VISITED_ONBOARDING_PAGE, page.index);
    notifyListeners();
  }

  OnboardingPage get lastVisitedOnboardingPage {
    final int? pageIndex =
        _sharedPreferences.getInt(_TAG_LAST_VISITED_ONBOARDING_PAGE);
    return pageIndex == null
        ? OnboardingPage.NOT_STARTED
        : OnboardingPage.values[pageIndex];
  }

  Future<void> setFirstScanAchieved() async {
    if (isFirstScan) {
      await _sharedPreferences.setBool(_TAG_IS_FIRST_SCAN, false);
      notifyListeners();
    }
  }

  bool get isFirstScan =>
      _sharedPreferences.getBool(_TAG_IS_FIRST_SCAN) ?? true;

  Future<void> setAppLanguageCode(String? languageCode) async {
    if (languageCode == null) {
      await _sharedPreferences
          .remove(UserPreferencesDevMode.userPreferencesAppLanguageCode);
    } else {
      await setDevModeString(
          UserPreferencesDevMode.userPreferencesAppLanguageCode, languageCode);
    }
    notifyListeners();
  }

  String? get appLanguageCode =>
      getDevModeString(UserPreferencesDevMode.userPreferencesAppLanguageCode);

  String _getFlagTag(final String key) => _TAG_PREFIX_FLAG + key;

  Future<void> setFlag(
    final String key,
    final bool? value,
  ) async {
    value == null
        ? await _sharedPreferences.remove(_getFlagTag(key))
        : await _sharedPreferences.setBool(_getFlagTag(key), value);
    notifyListeners();
  }

  bool? getFlag(final String key) =>
      _sharedPreferences.getBool(_getFlagTag(key));

  List<String> getExcludedAttributeIds() =>
      _sharedPreferences.getStringList(_TAG_EXCLUDED_ATTRIBUTE_IDS) ??
      <String>[];

  Future<void> setExcludedAttributeIds(final List<String> value) async {
    await _sharedPreferences.setStringList(_TAG_EXCLUDED_ATTRIBUTE_IDS, value);
    notifyListeners();
  }

  bool get useFlashWithCamera =>
      _sharedPreferences.getBool(_TAG_USE_FLASH_WITH_CAMERA) ?? false;

  Future<void> setUseFlashWithCamera(final bool useFlash) async {
    await _sharedPreferences.setBool(_TAG_USE_FLASH_WITH_CAMERA, useFlash);
    notifyListeners();
  }

  bool? get useAlternativeCameraMode =>
      _sharedPreferences.getBool(_TAG_CAMERA_USE_ALTERNATIVE_MODE);

  Future<void> setUseAlternativeCameraMode(final bool alternativeMode) async {
    await _sharedPreferences.setBool(
      _TAG_CAMERA_USE_ALTERNATIVE_MODE,
      alternativeMode,
    );

    notifyListeners();
  }

  Future<void> setPlayCameraSound(bool playSound) async {
    await _sharedPreferences.setBool(_TAG_PLAY_CAMERA_SCAN_SOUND, playSound);
    notifyListeners();
  }

  bool get playCameraSound =>
      _sharedPreferences.getBool(_TAG_PLAY_CAMERA_SCAN_SOUND) ?? false;

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    await _sharedPreferences.setBool(_TAG_HAPTIC_FEEDBACK_IN_APP, enabled);
    notifyListeners();
  }

  bool get hapticFeedbackEnabled =>
      _sharedPreferences.getBool(_TAG_HAPTIC_FEEDBACK_IN_APP) ?? true;

  Future<void> setDevMode(final int value) async {
    await _sharedPreferences.setInt(_TAG_DEV_MODE, value);
    notifyListeners();
  }

  int get devMode => _sharedPreferences.getInt(_TAG_DEV_MODE) ?? 0;

  Future<void> setDevModeIndex(final String tag, final int index) async {
    await _sharedPreferences.setInt(tag, index);
    notifyListeners();
  }

  int? getDevModeIndex(final String tag) => _sharedPreferences.getInt(tag);

  Future<void> setDevModeString(final String tag, final String value) async {
    await _sharedPreferences.setString(tag, value);
    notifyListeners();
  }

  String? getDevModeString(final String tag) =>
      _sharedPreferences.getString(tag);

  Future<void> setActiveAttributeGroup(final String value) async =>
      _sharedPreferences.setString(_TAG_ACTIVE_ATTRIBUTE_GROUP, value);

  String get activeAttributeGroup =>
      _sharedPreferences.getString(_TAG_ACTIVE_ATTRIBUTE_GROUP) ??
      'nutritional_quality'; // TODO(monsieurtanuki): relatively safe but not nice to put a hard-coded value (even when highly probable)
}
