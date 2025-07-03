import 'package:flutter/material.dart';
import 'package:scanner_shared/scanner_shared.dart';

/// Empty implementation for an [AppStore]
class MockedScanner extends Scanner {
  const MockedScanner();

  @override
  String getType() => 'Mocked';

  @override
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
    EdgeInsetsGeometry? contentPadding,
  }) => Container();
}
