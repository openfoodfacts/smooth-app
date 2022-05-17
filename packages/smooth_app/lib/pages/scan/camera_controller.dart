import 'package:camera/camera.dart';
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
  Future<void> pausePreview() {
    final Future<void> pausePreviewResult = super.pausePreview();
    _isPaused = true;
    return pausePreviewResult;
  }

  Future<void> resumePreviewIfNecessary() async {
    if (_isPaused) {
      return resumePreview();
    }
  }

  /// Please use [resumePreviewIfNecessary] instead
  @protected
  @override
  Future<void> resumePreview() {
    final Future<void> resumePreviewResult = super.resumePreview();
    _isPaused = false;
    return resumePreviewResult;
  }

  @override
  Future<void> stopImageStream() {
    final Future<void> stopImageStreamResult = super.stopImageStream();
    _isPaused = false;
    return stopImageStreamResult;
  }

  @override
  Future<void> dispose() {
    final Future<void> disposeResult = super.dispose();
    _isPaused = false;
    _isInitialized = false;
    return disposeResult;
  }

  bool get isPaused => _isPaused;
  bool get isInitialized => _isInitialized;
}
