import 'package:flutter/services.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

/// Haptic feedback/vibrations in the app
/// Managed by a preference in the user preferences
class SmoothHapticFeedback {
  const SmoothHapticFeedback._();

  /// Will vibrate smoothly twice
  static Future<void> confirm() async {
    if (!(await _areHapticFeedbackAvailable())) {
      return;
    }

    await HapticFeedback.lightImpact();
    return Future<void>.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Discrete vibration
  static Future<void> click() async {
    if (!(await _areHapticFeedbackAvailable())) {
      return;
    }

    return HapticFeedback.selectionClick();
  }

  /// According to the doc: "a collision impact with a light mass"
  static Future<void> lightNotification() async {
    if (!(await _areHapticFeedbackAvailable())) {
      return;
    }

    return HapticFeedback.lightImpact();
  }

  /// Will vibrate heavily twice
  static Future<void> error() async {
    if (!(await _areHapticFeedbackAvailable())) {
      return;
    }

    await HapticFeedback.heavyImpact();
    return Future<void>.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.heavyImpact();
    });
  }

  static Future<bool> _areHapticFeedbackAvailable() async {
    return UserPreferences.getUserPreferences()
        .then((UserPreferences userPreferences) {
      return userPreferences.hapticFeedbackEnabled;
    });
  }
}
