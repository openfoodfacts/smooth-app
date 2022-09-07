import 'package:flutter/services.dart';

class SmoothHapticFeedback {
  const SmoothHapticFeedback._();

  static Future<void> confirm() async {
    await HapticFeedback.lightImpact();
    return Future<void>.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });
  }

  static Future<void> click() {
    return HapticFeedback.selectionClick();
  }

  static Future<void> lightNotification() {
    return HapticFeedback.lightImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    return Future<void>.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.heavyImpact();
    });
  }
}
