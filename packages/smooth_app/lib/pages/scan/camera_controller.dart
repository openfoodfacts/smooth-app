import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/pages/scan/alternative_camera_mode.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// A lifecycle-aware [CameraController]
/// On Android it supports pause/resume feed
/// On iOS, pausing the feed will dispose the controller instead, as the camera
/// indicator stays on
class SmoothCameraController extends CameraController {
  SmoothCameraController(
    this.preferences,
    super.description,
    super.resolutionPreset, {
    super.imageFormatGroup,
  })  : _state = _CameraState.notInitialized,
        _hasAPendingResume = false,
        super(
          enableAudio: false,
        ) {
    Logs.d(tag: 'CameraController', 'New controller created');
  }

  final UserPreferences preferences;

  /// Status of the preview
  _CameraState _state;

  /// Flag to indicate that the [resumePreview] method was called, but
  /// [pausePreview] was still processing
  bool _hasAPendingResume;

  /// Listen to camera closed events
  StreamSubscription<CameraClosingEvent>? _closeListener;

  /// Listen to camera error events
  StreamSubscription<CameraErrorEvent>? _errorListener;

  /// Last focus point position
  Offset? _focusPoint;

  /// Does the camera use the alternative mode (file based implementation)?
  /// Enabled to [false] by default, as [changeImageMode] can be called, even if
  /// [init] wasn't called before.
  bool _persistToFileMode = false;

  Future<void> init({
    required FocusMode focusMode,
    required Offset focusPoint,
    required DeviceOrientation deviceOrientation,
    required onLatestImageAvailable onAvailable,
    bool? enableTorch,
  }) async {
    if (!isInitialized) {
      Logs.d(tag: 'CameraController', 'Controller is being initialized');
      _updateState(_CameraState.beingInitialized);
      await initialize();
      await setFocusMode(focusMode);
      await setExposurePoint(focusPoint);
      await setFocusPointTo(focusPoint);
      await lockCaptureOrientation(deviceOrientation);
      await startStream(onAvailable);
      await enableFlash(enableTorch ?? preferences.useFlashWithCamera);
      _updateState(_CameraState.initialized);
      _hasAPendingResume = false;

      _closeListener = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen((CameraClosingEvent event) async {
        value = value.markAsClosed();
        Logs.d(tag: 'CameraController', 'Camera closed!');
      });

      _errorListener = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen((CameraErrorEvent event) async {
        Logs.d(
            tag: 'CameraController', 'On camera error: ${event.description}');
      });

      _updateState(_CameraState.resumed);
    } else {
      Logs.w(tag: 'CameraController', 'Controller already initialized!');
    }
  }

  /// Please use [init] instead
  @protected
  @override
  Future<void> initialize() => super.initialize();

  @protected
  Future<void> startStream(onLatestImageAvailable onAvailable) async {
    _persistToFileMode = preferences.useAlternativeCameraMode ??
        await AlternativeCameraMode.isAWhitelistedDevice;

    return startImageStream(
      onAvailable,
      persistToFile: _persistToFileMode,
    );
  }

  Future<void> reloadImageMode() async {
    final bool? alternativeCameraMode = preferences.useAlternativeCameraMode;

    /// Keep using the default value
    if (alternativeCameraMode == null) {
      return;
    }

    if (alternativeCameraMode != _persistToFileMode) {
      _persistToFileMode = alternativeCameraMode;
      await changeImageMode(_persistToFileMode);
    }
  }

  /// Never use this method directly, use [reloadImageMode] instead
  @protected
  @override
  Future<bool> changeImageMode(bool persistToFile) {
    return super.changeImageMode(persistToFile);
  }

  /// Never use this method directly, by through [startStream]
  /// [persistToFile] is what we call the "alternative" mode
  @protected
  @override
  Future<void> startImageStream(
    onLatestImageAvailable onAvailable, {
    bool persistToFile = false,
  }) {
    final Future<void> startImageStreamResult = super.startImageStream(
      onAvailable,
      persistToFile: persistToFile,
    );

    Logs.d(
      tag: 'CameraController',
      persistToFile
          ? 'Image stream started with files'
          : 'Image stream started with camera stream',
    );

    return startImageStreamResult;
  }

  @override
  Future<void> pausePreview() async {
    if (!isPauseResumePreviewSupported) {
      throw UnimplementedError('This feature is not supported!');
    }

    if (_state != _CameraState.beingPaused) {
      Logs.d(tag: 'CameraController', 'Image stream being paused');
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

      Logs.d(tag: 'CameraController', 'Image stream paused');

      // If the pause process took too long, resume the camera if necessary
      if (_hasAPendingResume) {
        _hasAPendingResume = false;
        Logs.d(tag: 'CameraController', '');
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
      Logs.d(
          tag: 'CameraController',
          'Preview not paused, will be restarted later…');
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
      Logs.d(tag: 'CameraController', 'Resuming flash…');
      return enableFlash(preferences.useFlashWithCamera);
    }
  }

  Future<void> _pauseFlash() {
    // Don't persist value to preferences
    return setFlashMode(FlashMode.off).then(
      // A slight delay is required as the native part doesn't wait here
      (_) => Future<void>.delayed(SmoothAnimationsDuration.short),
    );
  }

  Future<void> enableFlash(bool enable) async {
    Logs.d(tag: 'CameraController', 'Changing flash state to: $enable');
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
    Logs.d(tag: 'CameraController', 'Image stream stopped');
    _updateState(_CameraState.stopped);
  }

  Future<void> setFocusPointTo(
    Offset? point,
  ) async {
    await setExposurePoint(point);
    await setFocusPoint(
      point,
      FocusPointMode.auto,
    );
    _focusPoint = point;
  }

  @protected
  @override
  Future<void> setFocusPoint(
    Offset? point,
    FocusPointMode? mode,
  ) async {
    await setExposurePointSafe(point);
    await super.setFocusPoint(point, mode);
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
    return setFocusPoint(_focusPoint, FocusPointMode.auto);
  }

  Future<void> forceFocus() async {
    if (isInitialized && _state == _CameraState.resumed) {
      return setFocusPointTo(_focusPoint);
    }
  }

  @override
  Future<void> dispose() async {
    _updateState(_CameraState.isBeingDisposed);
    _closeListener?.cancel();
    _errorListener?.cancel();
    await super.dispose();
    _updateState(_CameraState.disposed);
  }

  void _updateState(_CameraState newState) {
    if (newState != _state) {
      _state = newState;
      Logs.d(tag: 'CameraController', 'New camera state = $_state');

      // Notify the UI to ensure a setState is called
      if (_state == _CameraState.resumed) {
        notifyListeners();
      }
    }
  }

  @override
  Widget buildPreview() {
    try {
      return super.buildPreview();
    } catch (err) {
      if (err is CameraException && err.code == 'Disposed CameraController') {
        _updateState(_CameraState.disposed);
        // Just ignore the issue, a new Controller will be created
        // Issue reproducible on iOS
      }

      return const SizedBox.shrink();
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
