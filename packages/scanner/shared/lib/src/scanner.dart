import 'package:flutter/material.dart';

/// Base class for the Scanner interface…
abstract class Scanner {
  const Scanner();

  static const String ANALYTICS_CATEGORY = 'scanning';
  static const String ANALYTICS_STRANGE_RESTART = 'strange restart';
  static const String ANALYTICS_STRANGE_RESTOP = 'strange restop';

  String getType();

  Widget getScanner({
    required Future<bool> Function(String) onScan,
    required Future<void> Function() hapticFeedback,
    required Function(BuildContext)? onCameraFlashError,
    required Function(
      String msg,
      String category, {
      int? eventValue,
      String? barcode,
    })
    trackCustomEvent,
    required bool hasMoreThanOneCamera,
    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,

    /// Padding to apply to the content (eg: the visor)
    EdgeInsetsGeometry? contentPadding,
  });
}
