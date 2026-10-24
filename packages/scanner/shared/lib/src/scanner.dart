import 'package:flutter/material.dart';

abstract class CustomScannerController {
  bool get isStarted;

  Future<void> start();

  Future<void> stop();

  void onPause();

  void toggleCamera();

  /// Notifies when [hasTorch] or [isTorchOn] change.
  Listenable get hasTorchState;

  bool get hasTorch;

  bool get isTorchOn;

  void turnTorchOn();

  void turnTorchOff();

  Widget buildCameraView({required void Function(String barcode) onScan});
}

/// Base class for the Scanner interface…
abstract class Scanner {
  const Scanner();

  static const String ANALYTICS_CATEGORY = 'scanning';
  static const String ANALYTICS_STRANGE_RESTART = 'strange restart';
  static const String ANALYTICS_STRANGE_RESTOP = 'strange restop';

  String getType();

  CustomScannerController getController();

  Future<bool> hasCamera({required bool front});

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
    required Widget barcodeScannerIcon,
    required Widget torchOnIcon,
    required Widget torchOffIcon,

    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,

    /// Padding to apply to the content (eg: the visor)
    EdgeInsetsGeometry? contentPadding,
  });
}
