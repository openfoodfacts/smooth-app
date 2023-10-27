import 'dart:math';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/themes/color_schemes.dart';

part 'package:smooth_app/data_models/preferences/migration/user_preferences_migration.dart';

/// User choice regarding the picture source.
enum UserPictureSource {
  /// Always select between Gallery and Camera
  SELECT('S'),

  /// Always use Gallery
  GALLERY('G'),

  /// Always use Camera
  CAMERA('C');

  const UserPictureSource(this.tag);

  final String tag;

  static UserPictureSource get defaultValue => UserPictureSource.SELECT;

  static UserPictureSource fromString(final String tag) =>
      UserPictureSource.values
          .firstWhere((final UserPictureSource source) => source.tag == tag);
}

class UserPreferences extends ChangeNotifier {
  UserPreferences._shared(final SharedPreferences sharedPreferences)
      : _sharedPreferences = sharedPreferences {
    onCrashReportingChanged = ValueNotifier<bool>(crashReports);
    onAnalyticsChanged = ValueNotifier<bool>(userTracking);
  }

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

  late ValueNotifier<bool> onCrashReportingChanged;
  late ValueNotifier<bool> onAnalyticsChanged;

  /// Whether the preferences are empty or not
  static const String _TAG_INIT = 'init';

  /// The current version of preferences
  static const String _TAG_VERSION = 'prefs_version';
  static const int _PREFS_CURRENT_VERSION = 3;
  static const String _TAG_PREFIX_IMPORTANCE = 'IMPORTANCE_AS_STRING';
  static const String _TAG_CURRENT_THEME_MODE = 'currentThemeMode';
  static const String _TAG_CURRENT_COLOR_SCHEME = 'currentColorScheme';
  static const String _TAG_CURRENT_CONTRAST_MODE = 'contrastMode';
  static const String _TAG_USER_COUNTRY_CODE = 'userCountry';
  static const String _TAG_LAST_VISITED_ONBOARDING_PAGE =
      'lastVisitedOnboardingPage';
  static const String _TAG_PREFIX_FLAG = 'FLAG_PREFIX_';
  static const String _TAG_DEV_MODE = 'devMode';
  static const String _TAG_USER_TRACKING = 'user_tracking';
  static const String _TAG_CRASH_REPORTS = 'crash_reports';
  static const String _TAG_EXCLUDED_ATTRIBUTE_IDS = 'excluded_attributes';
  static const String _TAG_USER_GROUP = '_user_group';

  /// Camera preferences

  // Use the flash/torch with the camera
  static const String _TAG_USE_FLASH_WITH_CAMERA = 'enable_flash_with_camera';

  // Play sound when decoding a barcode
  static const String _TAG_PLAY_CAMERA_SCAN_SOUND = 'camera_scan_sound';

  /// Vibrations / haptic feedback
  static const String _TAG_HAPTIC_FEEDBACK_IN_APP = 'haptic_feedback_enabled';

  /// Attribute group that is not collapsed
  static const String _TAG_ACTIVE_ATTRIBUTE_GROUP = 'activeAttributeGroup';

  /// User picture source
  static const String _TAG_USER_PICTURE_SOURCE = 'userPictureSource';

  /// If the in-app review was asked at least one time (false by default)
  static const String _TAG_IN_APP_REVIEW_ALREADY_DISPLAYED =
      'inAppReviewAlreadyAsked';

  static const String _TAG_NUMBER_OF_SCANS = 'numberOfScans';

  Future<void> init(final ProductPreferences productPreferences) async {
    await _onMigrate();

    if (_sharedPreferences.getBool(_TAG_INIT) != null) {
      return;
    }
    await productPreferences.resetImportances();
    await _sharedPreferences.setBool(_TAG_INIT, true);
  }

  /// Allow to migrate between versions
  Future<void> _onMigrate() async {
    await UserPreferencesMigrationTool.onUpgrade(
      this,
      _sharedPreferences.getInt(_TAG_VERSION),
      _PREFS_CURRENT_VERSION,
    );

    await _sharedPreferences.setInt(
      _TAG_VERSION,
      UserPreferences._PREFS_CURRENT_VERSION,
    );
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

  Future<void> setColorScheme(final String color) async {
    await _sharedPreferences.setString(_TAG_CURRENT_COLOR_SCHEME, color);
    notifyListeners();
  }

  Future<void> setContrastScheme(final String contrastLevel) async {
    await _sharedPreferences.setString(
        _TAG_CURRENT_CONTRAST_MODE, contrastLevel);
    notifyListeners();
  }

  Future<void> setUserTracking(final bool state) async {
    await _sharedPreferences.setBool(_TAG_USER_TRACKING, state);
    onAnalyticsChanged.value = state;
    notifyListeners();
  }

  bool get userTracking =>
      _sharedPreferences.getBool(_TAG_USER_TRACKING) ?? false;

  /// A random int between 0 and 10 (a naive implementation to allow A/B testing)
  int get userGroup => _sharedPreferences.getInt(_TAG_USER_GROUP)!;

  Future<void> setCrashReports(final bool state) async {
    await _sharedPreferences.setBool(_TAG_CRASH_REPORTS, state);
    onCrashReportingChanged.value = state;
    notifyListeners();
  }

  bool get crashReports =>
      _sharedPreferences.getBool(_TAG_CRASH_REPORTS) ?? false;

  String get currentTheme =>
      _sharedPreferences.getString(_TAG_CURRENT_THEME_MODE) ?? 'System Default';

  String get currentColor =>
      _sharedPreferences.getString(_TAG_CURRENT_COLOR_SCHEME) ??
      COLOR_DEFAULT_NAME;

  String get currentContrastLevel =>
      _sharedPreferences.getString(_TAG_CURRENT_CONTRAST_MODE) ??
      CONTRAST_MEDIUM;

  /// Please use [ProductQuery.setCountry] as interface
  Future<void> setUserCountryCode(final String countryCode) async {
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

  Future<void> resetOnboarding() async {
    await setLastVisitedOnboardingPage(OnboardingPage.NOT_STARTED);
    // for tests with a fresh null country
    await _sharedPreferences.remove(_TAG_USER_COUNTRY_CODE);
    notifyListeners();
  }

  OnboardingPage get lastVisitedOnboardingPage {
    final int? pageIndex =
        _sharedPreferences.getInt(_TAG_LAST_VISITED_ONBOARDING_PAGE);
    return pageIndex == null
        ? OnboardingPage.NOT_STARTED
        : OnboardingPage.values[pageIndex];
  }

  Future<void> incrementScanCount() async {
    await _sharedPreferences.setInt(_TAG_NUMBER_OF_SCANS, numberOfScans + 1);
    notifyListeners();
  }

  int get numberOfScans => _sharedPreferences.getInt(_TAG_NUMBER_OF_SCANS) ?? 0;

  Future<void> markInAppReviewAsShown() async {
    await _sharedPreferences.setBool(
      _TAG_IN_APP_REVIEW_ALREADY_DISPLAYED,
      true,
    );
    notifyListeners();
  }

  bool get inAppReviewAlreadyAsked =>
      _sharedPreferences.getBool(_TAG_IN_APP_REVIEW_ALREADY_DISPLAYED) ?? false;

  /// Please use [ProductQuery.setLanguage] as interface
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

  /// Please use [ProductQuery.getLanguage] as interface
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

  Future<void> setDevModeString(final String tag, final String value) async {
    await _sharedPreferences.setString(tag, value);
    notifyListeners();
  }

  String? getDevModeString(final String tag) =>
      _sharedPreferences.getString(tag);

  Future<void> setActiveAttributeGroup(final String value) async {
    await _sharedPreferences.setString(_TAG_ACTIVE_ATTRIBUTE_GROUP, value);
    notifyListeners();
  }

  String get activeAttributeGroup =>
      _sharedPreferences.getString(_TAG_ACTIVE_ATTRIBUTE_GROUP) ??
      'nutritional_quality'; // TODO(monsieurtanuki): relatively safe but not nice to put a hard-coded value (even when highly probable)

  UserPictureSource get userPictureSource => UserPictureSource.fromString(
        _sharedPreferences.getString(_TAG_USER_PICTURE_SOURCE) ??
            UserPictureSource.defaultValue.tag,
      );

  Future<void> setUserPictureSource(final UserPictureSource source) async {
    await _sharedPreferences.setString(_TAG_USER_PICTURE_SOURCE, source.tag);
    notifyListeners();
  }
}
