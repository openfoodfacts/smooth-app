import 'package:flutter/material.dart';
import 'package:scanner_shared/scanner_shared.dart';

/// Empty implementation for an [AppStore]
class MockedScanner extends Scanner {
  const MockedScanner();

  @override
  String getType() => 'Mocked';

  @override
  CustomScannerController getController() => _MockedScannerController();

  @override
  Future<bool> hasCamera({required bool front}) async => true;

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
    required Widget barcodeScannerIcon,
    required Widget torchOnIcon,
    required Widget torchOffIcon,
    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,
    EdgeInsetsGeometry? contentPadding,
  }) => const SizedBox.shrink();
}

class _MockedScannerController implements CustomScannerController {
  @override
  bool get isStarted => false;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  void onPause() {}

  @override
  void toggleCamera() {}

  @override
  Listenable get hasTorchState => ChangeNotifier();

  @override
  bool get hasTorch => false;

  @override
  bool get isTorchOn => false;

  @override
  void turnTorchOn() {}

  @override
  void turnTorchOff() {}

  @override
  Widget buildCameraView({required void Function(String barcode) onScan}) =>
      const SizedBox.shrink();
}
