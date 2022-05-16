import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/scan/lifecycle_manager.dart';
import 'package:smooth_app/pages/scan/mkit_scan_helper.dart';
import 'package:smooth_app/widgets/lifecycle_aware_widget.dart';
import 'package:smooth_app/widgets/screen_visibility.dart';

class MLKitScannerPage extends StatelessWidget {
  const MLKitScannerPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenVisibilityDetector(
      child: _MLKitScannerPageContent(),
    );
  }
}

class _MLKitScannerPageContent extends LifecycleAwareStatefulWidget {
  const _MLKitScannerPageContent({
    Key? key,
  }) : super(key: key);

  @override
  MLKitScannerPageState createState() => MLKitScannerPageState();
}

class MLKitScannerPageState
    extends LifecycleAwareState<_MLKitScannerPageContent> {
  /// If the camera is being closed (when [stoppingCamera] == true) and this
  /// Widget is visible again, we add a post frame callback to detect if the
  /// Widget is still visible
  ///
  /// If the time took by the "post frame callback" is less than this duration,
  /// we considered, that the camera should be reinitialized
  ///
  /// On a 60Hz display, one frame =~ 16 ms => 100 ms =~ 6 frames.
  static const int postFrameCallbackStandardDelay = 100; // in milliseconds

  /// To improve battery life & lower the CPU consumption, we decode barcodes
  /// every [_processingTimeWindows] time windows.

  /// Until the first barcode is decoded, this is default timeout
  static const int _defaultProcessingTime = 50; // in milliseconds
  /// Minimal processing windows between two decodings
  static const int _processingTimeWindows = 5;

  /// A time window is the average time decodings took
  final AverageList<int> _averageProcessingTime = AverageList<int>();

  /// Subject notifying when a new image is available
  PublishSubject<CameraImage> _subject = PublishSubject<CameraImage>();

  /// Stream calling the barcode detection
  StreamSubscription<List<String>?>? _streamSubscription;
  MLKitScanDecoder? _barcodeDecoder;

  late ContinuousScanModel _model;
  late UserPreferences _userPreferences;
  CameraController? _controller;
  CameraDescription? _camera;
  double _previewScale = 1.0;

  /// Flag used to prevent the camera from being initialized.
  /// When set to [false], [_startLiveStream] can be called.
  bool stoppingCamera = false;

  @override
  void initState() {
    super.initState();
    _camera = CameraHelper.findBestCamera();
    _subject = PublishSubject<CameraImage>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (mounted) {
      _model = context.watch<ContinuousScanModel>();
      _userPreferences = context.watch<UserPreferences>();
    }

    // Relaunch the feed after a hot reload
    if (_controller == null) {
      _startLiveFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // [_startLiveFeed] is called both with [onResume] and [onPause] to cover
    // all entry points
    return LifeCycleManager(
      onStart: _startLiveFeed,
      onResume: _startLiveFeed,
      onPause: () => _stopImageStream(fromPauseEvent: true),
      child: _buildScannerWidget(),
    );
  }

  Widget _buildScannerWidget() {
    // Showing the black scanner background + the icon when the scanner is
    // loading or stopped
    if (isCameraNotInitialized) {
      return const SizedBox.shrink();
    }

    final Size size = MediaQuery.of(context).size;
    // From: https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched/61487358#61487358:
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    _previewScale = size.aspectRatio * _controller!.value.aspectRatio;

    if (_previewScale < 1.0) {
      // To prevent scaling down, invert the value
      _previewScale = 1.0 / _previewScale;
    } else {
      // Scale up the size if the preview doesn't take the full width or height
      _previewScale = _controller!.value.aspectRatio - size.aspectRatio;
    }

    return Transform.scale(
      scale: _previewScale,
      child: Center(
        key: ValueKey<bool>(stoppingCamera),
        child: CameraPreview(
          _controller!,
        ),
      ),
    );
  }

  bool get isCameraNotInitialized {
    return _controller == null ||
        _controller!.value.isInitialized == false ||
        stoppingCamera ||
        _controller!.value.isPreviewPaused ||
        !_controller!.value.isStreamingImages;
  }

  Future<void> _startLiveFeed() async {
    if (_controller != null || _camera == null) {
      return;
    }

    stoppingCamera = false;

    _controller = CameraController(
      _camera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // If the controller is initialized update the UI.
    _barcodeDecoder ??= MLKitScanDecoder(
      camera: _camera!,
      scanMode: DevModeScanModeExtension.fromIndex(
        _userPreferences.getDevModeIndex(
          UserPreferencesDevMode.userPreferencesEnumScanMode,
        ),
      ),
    );
    _controller?.addListener(_cameraListener);

    // Restart the subscription if necessary
    if (_streamSubscription?.isPaused == true) {
      _streamSubscription!.resume();
    } else {
      _subject
          .throttleTime(
            Duration(
              milliseconds:
                  _averageProcessingTime.average(_defaultProcessingTime) *
                      _processingTimeWindows,
            ),
          )
          .asyncMap((CameraImage image) async {
            final DateTime start = DateTime.now();

            final List<String?>? res =
                await _barcodeDecoder?.processImage(image);

            _averageProcessingTime.add(
              DateTime.now().difference(start).inMilliseconds,
            );

            return res;
          })
          .where(
            (List<String?>? barcodes) => barcodes?.isNotEmpty == true,
          )
          .cast<List<String>>()
          .listen(_onNewBarcodeDetected);
    }

    try {
      await _controller?.initialize();
      await _controller?.setFocusMode(FocusMode.auto);
      await _controller?.setFocusPoint(_focusPoint);
      await _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await _controller?.startImageStream(
        (CameraImage image) => _subject.add(image),
      );
    } on CameraException catch (e) {
      if (kDebugMode) {
        // TODO(M123): Show error message
        debugPrint(e.toString());
      }
    }

    _redrawScreen();
  }

  Future<void> _onNewBarcodeDetected(List<String> barcodes) async {
    for (final String barcode in barcodes) {
      if (await _model.onScan(barcode)) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _cameraListener() {
    if (_controller?.value.hasError == true) {
      // TODO(M123): Handle errors better
      debugPrint(_controller!.value.errorDescription);
    }
  }

  Future<void> _stopImageStream({bool fromPauseEvent = false}) async {
    if (stoppingCamera) {
      return;
    }

    stoppingCamera = true;
    _redrawScreen();

    _controller?.removeListener(_cameraListener);

    if (fromPauseEvent) {
      _streamSubscription?.pause();
    } else {
      await _streamSubscription?.cancel();
    }

    await _controller?.dispose();
    await _barcodeDecoder?.dispose();

    _barcodeDecoder = null;
    _controller = null;

    _restartCameraIfNecessary();
  }

  void _redrawScreen() {
    setStateSafe(() {});
  }

  /// The camera is fully closed at this step.
  /// However, the user may have "reopened" this Widget during this
  /// operation. In this case, [_startLiveFeed] should be called.
  ///
  /// To detect this behavior, we compute the time took by
  /// [addPostFrameCallback]. If it's less than a few frames, it means the
  /// camera should be restarted immediately
  void _restartCameraIfNecessary() {
    if (mounted && ScreenVisibilityDetector.visible(context)) {
      final DateTime referentialTime = DateTime.now();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final int diff =
            DateTime.now().difference(referentialTime).inMilliseconds;

        // The screen is still visible, we should restart the camera
        if (diff < _minPostFrameCallbackDelay) {
          _startLiveFeed();
        }
      });
    }
  }

  int get _minPostFrameCallbackDelay =>
      _userPreferences.getDevModeIndex(
        UserPreferencesDevMode.userPreferencesCameraPostFrameDuration,
      ) ??
      MLKitScannerPageState.postFrameCallbackStandardDelay;

  @override
  void dispose() {
    // /!\ This call is a Future, which may leads to some issues.
    // This should be handled by [_restartCameraIfNecessary]
    _stopImageStream(fromPauseEvent: false);
    super.dispose();
  }

  /// Whatever the scan mode is, we always want the focus point to be on
  /// "half-top" of the screen
  Offset get _focusPoint {
    if (_previewScale == 1.0) {
      return const Offset(0.5, 0.25);
    } else {
      // Since we use a [Alignment.topCenter] alignment for the preview, we
      // have to recompute the position of the focus point
      return Offset(0.5, 0.25 / _previewScale);
    }
  }
}
