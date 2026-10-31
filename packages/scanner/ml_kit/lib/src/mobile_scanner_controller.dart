import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanner_shared/scanner_shared.dart';

class MLKitScannerController implements CustomScannerController {
  MLKitScannerController(this._controller)
    : _torchState = ScannerTorchState(),
      _availableCamerasState = AvailableCamerasState(),
      _cameraFacingState = CameraFacingState();

  final MobileScannerController _controller;
  final ScannerTorchState _torchState;
  final AvailableCamerasState _availableCamerasState;
  final CameraFacingState _cameraFacingState;

  bool _isStarted = false;
  bool _isStarting = false;
  bool _isClosing = false;
  bool _isClosed = false;

  @override
  Future<void> start() async {
    if (isStarted || _isStarting || isClosing) {
      return;
    }

    _isStarting = true;
    _isClosed = false;
    try {
      _controller.addListener(_onControllerChanged);
      await _controller.start();
      _isStarted = true;

      if (isTorchOn) {
        // Slight delay, because it doesn't always work if called immediately
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          turnTorchOn();
        });
      }
      _isStarting = false;
    } catch (_) {}
  }

  @override
  void onPause() {
    _isStarted = false;
    _isStarting = false;
    _isClosing = false;
    _isClosed = false;
  }

  void _onControllerChanged() {
    _availableCamerasState.value = _controller.value.availableCameras ?? 0;
    _cameraFacingState.value = _controller.facing;
    _torchState.value = _controller.value.torchState;
  }

  MobileScannerController get controller => _controller;

  @override
  bool get isStarted => _isStarted;

  bool get isClosing => _isClosing;

  bool get isClosed => _isClosed;

  @override
  Future<void> stop() async {
    if (isClosed || isClosing || _isStarting) {
      return;
    }

    _isClosing = true;
    _isStarting = false;
    _isStarted = false;
    try {
      await _controller.stop();
      _controller.removeListener(_onControllerChanged);
      _isClosing = false;
      _isClosed = true;
    } catch (_) {}
  }

  @override
  bool get hasTorch => _torchState.value != null;

  @override
  ValueNotifier<TorchState?> get hasTorchState => _torchState;

  // ugly
  @override
  bool get isTorchOn => _torchState.value == TorchState.on;

  @override
  void turnTorchOff() {
    if (isTorchOn) {
      unawaited(_controller.toggleTorch());
    }
  }

  @override
  void turnTorchOn() {
    if (!isTorchOn) {
      unawaited(_controller.toggleTorch());
    }
  }

  void toggleTorch() {
    if (isTorchOn) {
      turnTorchOff();
    } else {
      turnTorchOn();
    }
  }

  ValueNotifier<int> get availableCameras => _availableCamerasState;

  ValueNotifier<CameraFacing> get cameraFacing => _cameraFacingState;

  @override
  void toggleCamera() {
    _controller.switchCamera();
    if (_controller.facing == CameraFacing.front) {
      _torchState.value = null;
      _cameraFacingState.value = CameraFacing.front;
    } else if (_controller.facing == CameraFacing.front) {
      _torchState.value = TorchState.off;
      _cameraFacingState.value = CameraFacing.back;
    }
  }

  Future<void> dispose() => _controller.dispose();

  @override
  Widget buildCameraView({required void Function(String barcode) onScan}) =>
      MobileScanner(
        controller: _controller,
        placeholderBuilder: (_) =>
            const SizedBox.expand(child: ColoredBox(color: Colors.black)),
        onDetect: (BarcodeCapture capture) {
          final String? value = capture.barcodes.firstOrNull?.rawValue;
          if (value != null) {
            onScan(value);
          }
        },
      );
}

class ScannerTorchState extends ValueNotifier<TorchState?> {
  ScannerTorchState({TorchState? value}) : super(value);
}

class AvailableCamerasState extends ValueNotifier<int> {
  AvailableCamerasState() : super(0);
}

class CameraFacingState extends ValueNotifier<CameraFacing> {
  CameraFacingState() : super(CameraFacing.back);
}
