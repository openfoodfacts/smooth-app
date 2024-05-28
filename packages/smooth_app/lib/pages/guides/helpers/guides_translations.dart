import 'dart:ui';

import 'package:crowdin_sdk/crowdin_sdk.dart';

// ignore_for_file: avoid_classes_with_only_static_members

/// All sentences are downloaded via Crowdin
/// This is a temporary solution
/// /!\ Please do not use it for another feature in the app
class GuidesTranslations {
  static bool _initialized = false;
  static Locale? _locale;

  static Future<void> init(Locale locale) async {
    if (!_initialized) {
      await Crowdin.init(
        distributionHash: '04491cd52901e762d3e15a7gg9g',
        updatesInterval: const Duration(days: 1),
        withRealTimeUpdates: false,
      );
      _initialized = true;
    }

    if (_locale == null || _locale != locale) {
      await Crowdin.loadTranslations(locale);
      _locale = locale;
    }
  }

  static bool isInitialized() => _initialized && _locale != null;
}

/// Extension to call "my_key".translation
extension GuidesTranslationsExtension on String {
  // The locale is not used here, even if asked by the API…
  String get translation => Crowdin.getText('', this) ?? '';
}
