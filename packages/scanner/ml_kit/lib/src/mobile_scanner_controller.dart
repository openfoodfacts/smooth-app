import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:torch_light/torch_light.dart';

class CustomScannerController {
  CustomScannerController({required MobileScannerController controller})
    : _controller = controller,
      _torchState = TorchState(),
      _availableCamerasState = AvailableCamerasState(),
      _cameraFacingState = CameraFacingState() {
    _detectTorch();
  }

  final MobileScannerController _controller;
  final TorchState _torchState;
  final AvailableCamerasState _availableCamerasState;
  final CameraFacingState _cameraFacingState;

  bool _isStarted = false;
  bool _isStarting = false;
  bool _isClosing = false;
  bool _isClosed = false;

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

  void _onControllerChanged() {
    _availableCamerasState.value = _controller.value.availableCameras ?? 0;
    _cameraFacingState.value = _controller.facing;
  }

  MobileScannerController get controller => _controller;

  bool get isStarted => _isStarted;

  bool get isClosing => _isClosing;

  bool get isClosed => _isClosed;

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

  bool get hasTorch => _torchState.value != null;

  ValueNotifier<bool?> get hasTorchState => _torchState;

  bool get isTorchOn => _torchState.value == true;

  void turnTorchOff() {
    if (isTorchOn) {
      _controller.toggleTorch();
      _torchState.value = false;
    }
  }

  void turnTorchOn() {
    if (!isTorchOn) {
      _controller.toggleTorch();
      _torchState.value = true;
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

  void toggleCamera() {
    _controller.switchCamera();
    if (_controller.facing == CameraFacing.front) {
      _torchState.value = null;
      _cameraFacingState.value = CameraFacing.front;
    } else if (_controller.facing == CameraFacing.front) {
      _torchState.value = false;
      _cameraFacingState.value = CameraFacing.back;
    }
  }

  Future<void> _detectTorch() async {
    try {
      final bool isTorchAvailable = await TorchLight.isTorchAvailable();
      if (isTorchAvailable) {
        _torchState.value = false;
      } else {
        _torchState.value = null;
      }
    } on Exception catch (_) {}
  }

  Future<void> dispose() => _controller.dispose();
}

class TorchState extends ValueNotifier<bool?> {
  TorchState({bool? value}) : super(value);
}

class AvailableCamerasState extends ValueNotifier<int> {
  AvailableCamerasState() : super(0);
}

class CameraFacingState extends ValueNotifier<CameraFacing> {
  CameraFacingState() : super(CameraFacing.back);
}
