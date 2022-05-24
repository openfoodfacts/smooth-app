import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A lifecycle-aware [CameraController]
class SmoothCameraController extends CameraController {
  SmoothCameraController(
    CameraDescription description,
    ResolutionPreset resolutionPreset, {
    bool? enableAudio,
    ImageFormatGroup? imageFormatGroup,
  })  : _isPaused = false,
        _isInitialized = false,
        super(
          description,
          resolutionPreset,
          enableAudio: enableAudio ?? true,
          imageFormatGroup: imageFormatGroup,
        );

  /// Status of the preview
  bool _isPaused;

  /// Status of the controller
  bool _isInitialized;

  /// Listen to camera closed events
  StreamSubscription<CameraClosingEvent>? _closeListener;

  Future<void> init({
    required FocusMode focusMode,
    required Offset focusPoint,
    required DeviceOrientation deviceOrientation,
    required onLatestImageAvailable onAvailable,
  }) async {
    if (!_isInitialized) {
      await initialize();
      await setFocusMode(focusMode);
      await setFocusPoint(focusPoint);
      await setExposurePoint(focusPoint);
      await lockCaptureOrientation(deviceOrientation);
      await startImageStream(onAvailable);
      _isInitialized = true;

      _closeListener = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen((CameraClosingEvent event) async {
        value = value.markAsClosed();
      });
    }
  }

  /// Please use [init] instead
  @protected
  @override
  Future<void> initialize() => super.initialize();

  @override
  Future<void> startImageStream(onLatestImageAvailable onAvailable) {
    final Future<void> startImageStreamResult =
        super.startImageStream(onAvailable);
    _isPaused = false;
    return startImageStreamResult;
  }

  @override
  Future<void> pausePreview() async {
    await super.pausePreview();
    _isPaused = true;
  }

  Future<void> resumePreviewIfNecessary() async {
    if (_isPaused) {
      return resumePreview();
    }
  }

  /// Please use [resumePreviewIfNecessary] instead
  @protected
  @override
  Future<void> resumePreview() async {
    await super.resumePreview();
    _isPaused = false;
  }

  @override
  Future<void> stopImageStream() async {
    await super.stopImageStream();
    _isPaused = false;
  }

  @override
  Future<void> dispose() async {
    _closeListener?.cancel();
    _isInitialized = false;
    await super.dispose();
    _isPaused = false;
  }

  bool get isPaused => _isPaused;

  bool get isInitialized => _isInitialized;
}

extension CameraValueExtension on CameraValue {
  static const String _cameraClosedDescription = 'Camera closed';

  CameraValue markAsClosed() => copyWith(
        errorDescription: _cameraClosedDescription,
      );

  bool get isClosed => errorDescription == _cameraClosedDescription;
}
