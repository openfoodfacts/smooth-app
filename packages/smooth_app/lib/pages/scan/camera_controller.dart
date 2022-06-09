import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

/// A lifecycle-aware [CameraController]
/// On Android it supports pause/resume feed
/// On iOS, pausing the feed will dispose the controller instead, as the camera
/// indicator stays on
class SmoothCameraController extends CameraController {
  SmoothCameraController(
    this.preferences,
    CameraDescription description,
    ResolutionPreset resolutionPreset, {
    ImageFormatGroup? imageFormatGroup,
  })  : _state = _CameraState.notInitialized,
        _hasAPendingResume = false,
        super(
          description,
          resolutionPreset,
          enableAudio: false,
          imageFormatGroup: imageFormatGroup,
        );

  final UserPreferences preferences;

  /// Status of the preview
  _CameraState _state;

  /// Flag to indicate that the [resumePreview] method was called, but
  /// [pausePreview] was still processing
  bool _hasAPendingResume;

  /// Listen to camera closed events
  StreamSubscription<CameraClosingEvent>? _closeListener;

  Offset? _focusPoint;

  Future<void> init({
    required FocusMode focusMode,
    required Offset focusPoint,
    required DeviceOrientation deviceOrientation,
    required onLatestImageAvailable onAvailable,
    bool? enableTorch,
  }) async {
    if (!isInitialized) {
      _updateState(_CameraState.beingInitialized);
      await initialize();
      await setFocusMode(focusMode);
      await setExposurePoint(focusPoint);
      await setFocusPoint(focusPoint);
      await lockCaptureOrientation(deviceOrientation);
      await startImageStream(onAvailable);
      await enableFlash(enableTorch ?? preferences.useFlashWithCamera);
      _updateState(_CameraState.initialized);
      _hasAPendingResume = false;

      _closeListener = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen((CameraClosingEvent event) async {
        value = value.markAsClosed();
      });

      _updateState(_CameraState.resumed);
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
    return startImageStreamResult;
  }

  @override
  Future<void> pausePreview() async {
    if (!isPauseResumePreviewSupported) {
      throw UnimplementedError('This feature is not supported!');
    }

    if (_state != _CameraState.beingPaused) {
      _updateState(_CameraState.beingPaused);

      try {
        await _pauseFlash();
      } catch (exception) {
        // Camera already disposed
      }

      try {
        await super.pausePreview();
      } catch (exception) {
        // Camera already disposed
      }

      _updateState(_CameraState.paused);

      // If the pause process took too long, resume the camera if necessary
      if (_hasAPendingResume) {
        _hasAPendingResume = false;
        resumePreviewIfNecessary();
      }
    }
  }

  Future<void> resumePreviewIfNecessary() async {
    if (!isPauseResumePreviewSupported) {
      throw UnimplementedError('This feature is not supported!');
    } else if (_state == _CameraState.beingPaused) {
      // The pause process can sometimes be too long, in that case, we just for
      // it to be finished
      _hasAPendingResume = true;
      debugPrint('Preview not paused, will be restarted later…');
      return;
    } else if (_state == _CameraState.paused) {
      return resumePreview();
    }
  }

  /// Please use [resumePreviewIfNecessary] instead
  @protected
  @override
  Future<void> resumePreview() async {
    _updateState(_CameraState.beingResumed);
    await super.resumePreview();
    await _resumeFlash();
    await refocus();
    _updateState(_CameraState.resumed);
    notifyListeners();
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
    _updateState(_CameraState.stopped);
  }

  @override
  Future<void> setFocusPoint(Offset? point) async {
    await setExposurePointSafe(point);
    await super.setFocusPoint(point);
    _focusPoint = point;
  }

  /// This method may fail on some devices, but as it's not mandatory, we can
  /// ignore Exceptions
  Future<void> setExposurePointSafe(Offset? point) async {
    try {
      return super.setExposurePoint(point);
    } catch (_) {}
  }

  /// Force the focus to the latest call to [setFocusPoint].
  Future<void> refocus() async {
    return setFocusPoint(_focusPoint);
  }

  @override
  Future<void> dispose() async {
    _updateState(_CameraState.isBeingDisposed);
    _closeListener?.cancel();
    await super.dispose();
    _updateState(_CameraState.disposed);
  }

  void _updateState(_CameraState newState) {
    if (newState != _state) {
      _state = newState;
      debugPrint('New camera state = $_state');

      // Notify the UI to ensure a setState is called
      if (_state == _CameraState.resumed) {
        notifyListeners();
      }
    }
  }

  bool get isPaused => _state == _CameraState.paused;

  bool get isInitialized => !<_CameraState>[
        _CameraState.notInitialized,
        _CameraState.beingInitialized,
        _CameraState.isBeingDisposed,
        _CameraState.disposed,
      ].contains(_state);

  bool get canShowPreview => isInitialized && _state == _CameraState.resumed;

  bool get isBeingInitialized => _state == _CameraState.beingInitialized;

  bool get isPauseResumePreviewSupported => !Platform.isIOS;
}

extension CameraValueExtension on CameraValue {
  static const String _cameraClosedDescription = 'Camera closed';

  CameraValue markAsClosed() => copyWith(
        errorDescription: _cameraClosedDescription,
      );

  bool get isClosed => errorDescription == _cameraClosedDescription;
}

enum _CameraState {
  notInitialized,
  beingInitialized,
  initialized,
  beingPaused,
  paused,
  beingResumed,
  resumed,
  stopped,
  isBeingDisposed,
  disposed,
}
