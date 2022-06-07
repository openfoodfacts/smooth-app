import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

/// A lifecycle-aware [CameraController]
class SmoothCameraController extends CameraController {
  SmoothCameraController(
    this.preferences,
    CameraDescription description,
    ResolutionPreset resolutionPreset, {
    ImageFormatGroup? imageFormatGroup,
  })  : _isPaused = false,
        _isInitialized = false,
        _isBeingInitialized = false,
        super(
          description,
          resolutionPreset,
          enableAudio: false,
          imageFormatGroup: imageFormatGroup,
        );

  final UserPreferences preferences;

  /// Status of the preview
  bool _isPaused;

  /// Status of the controller
  bool _isInitialized;

  /// Indicates if the [init] method is in progress
  bool _isBeingInitialized;

  /// Listen to camera closed events
  StreamSubscription<CameraClosingEvent>? _closeListener;

  Future<void> init({
    required FocusMode focusMode,
    required Offset focusPoint,
    required DeviceOrientation deviceOrientation,
    required onLatestImageAvailable onAvailable,
    bool? enableTorch,
  }) async {
    if (!_isInitialized && !_isBeingInitialized) {
      _isBeingInitialized = true;
      await initialize();
      await setFocusMode(focusMode);
      await setFocusPoint(focusPoint);
      await setExposurePoint(focusPoint);
      await lockCaptureOrientation(deviceOrientation);
      await startImageStream(onAvailable);
      await enableFlash(enableTorch ?? preferences.useFlashWithCamera);
      _isInitialized = true;
      _isBeingInitialized = false;

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
    if (_isInitialized) {
      await _pauseFlash();
      await super.pausePreview();
      _isPaused = true;
    }
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
    await _resumeFlash();
    _isPaused = false;
  }

  Future<void> _resumeFlash() async {
    if (preferences.useFlashWithCamera) {
      return enableFlash(preferences.useFlashWithCamera);
    }
  }

  Future<void> _pauseFlash() {
    // Don't persist value to preferences
    return setFlashMode(FlashMode.off).then(
      // A slight delay is required as the native part doesn't wait here
      (_) => Future<void>.delayed(
        const Duration(milliseconds: 250),
      ),
    );
  }

  Future<void> enableFlash(bool enable) async {
    await setFlashMode(enable ? FlashMode.torch : FlashMode.off);
    await preferences.setUseFlashWithCamera(enable);
  }

  /// Please use [enableFlash] instead
  @protected
  @override
  Future<void> setFlashMode(FlashMode mode) {
    return super.setFlashMode(mode);
  }

  bool get isFlashModeEnabled {
    return value.flashMode == FlashMode.torch;
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

  bool get isBeingInitialized => _isBeingInitialized;
}

extension CameraValueExtension on CameraValue {
  static const String _cameraClosedDescription = 'Camera closed';

  CameraValue markAsClosed() => copyWith(
        errorDescription: _cameraClosedDescription,
      );

  bool get isClosed => errorDescription == _cameraClosedDescription;
}
