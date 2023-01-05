import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/query/product_query.dart';

/// Haptic feedback/vibrations in the app
/// Managed by a preference in the user's preferences
class SmoothHapticFeedback {
  const SmoothHapticFeedback._();

  /// Will vibrate smoothly twice
  static Future<void> confirm() async {
    if (!(await _areHapticFeedbackEnabled())) {
      return;
    }

    await HapticFeedback.lightImpact();
    return Future<void>.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Discrete vibration
  static Future<void> click() async {
    if (!(await _areHapticFeedbackEnabled())) {
      return;
    }

    return HapticFeedback.selectionClick();
  }

  /// According to the doc: "a collision impact with a light mass"
  static Future<void> lightNotification() async {
    if (!(await _areHapticFeedbackEnabled())) {
      return;
    }

    return HapticFeedback.lightImpact();
  }

  /// Will vibrate heavily twice
  static Future<void> error() async {
    if (!(await _areHapticFeedbackEnabled())) {
      return;
    }

    await HapticFeedback.heavyImpact();
    return Future<void>.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.heavyImpact();
    });
  }

  static Future<bool> _areHapticFeedbackEnabled() async {
    return UserPreferences.getUserPreferences()
        .then((UserPreferences userPreferences) {
      return userPreferences.hapticFeedbackEnabled;
    });
  }

  static String getFeedbackFormLink() {
    final String languageCode = ProductQuery.getLanguage().code;
    if (languageCode == 'en') {
      return 'https://forms.gle/AuNZG6fXyAPqN5tL7';
    } else if (languageCode == 'de') {
      return 'https://forms.gle/vCurhD2Y3ewS1YPv5';
    } else if (languageCode == 'es') {
      return 'https://forms.gle/CSMmuzR8i4LJBjbM9';
    } else if (languageCode == 'fr') {
      return 'https://forms.gle/cTR4wqGmW7pGUiaBA';
    } else if (languageCode == 'it') {
      return 'https://forms.gle/9HcCLFznym1ByQgB6';
    } else {
      return 'https://forms.gle/AuNZG6fXyAPqN5tL7';
    }
  }
}
