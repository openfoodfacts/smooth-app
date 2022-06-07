import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/pages/page_manager.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/scan/camera_controller.dart';
import 'package:smooth_app/pages/scan/lifecycle_manager.dart';
import 'package:smooth_app/pages/scan/mkit_scan_helper.dart';
import 'package:smooth_app/widgets/lifecycle_aware_widget.dart';
import 'package:smooth_app/widgets/screen_visibility.dart';

class MLKitScannerPage extends LifecycleAwareStatefulWidget {
  const MLKitScannerPage({
    Key? key,
  }) : super(key: key);

  @override
  MLKitScannerPageState createState() => MLKitScannerPageState();
}

class MLKitScannerPageState extends LifecycleAwareState<MLKitScannerPage>
    with TraceableClientMixin {
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
  final AudioCache _musicPlayer = AudioCache(prefix: 'assets/audio/');

  /// Subject notifying when a new image is available
  PublishSubject<CameraImage> _subject = PublishSubject<CameraImage>();

  /// Stream calling the barcode detection
  StreamSubscription<List<String>?>? _streamSubscription;
  MLKitScanDecoder? _barcodeDecoder;

  late ContinuousScanModel _model;
  late UserPreferences _userPreferences;
  CameraDescription? _camera;

  /// Camera preview scale
  double _previewScale = 1.0;

  /// Allow to detect if we have to recompute the [_previewScale]
  BoxConstraints? _contentConstraints;

  /// Flag used to prevent the camera from being initialized.
  /// When set to [false], [_startLiveStream] can be called.
  bool stoppingCamera = false;

  /// Flag used to determine when the app is resumed, the controller is disposed
  /// (another app acquired the camera in background), but the current tab is
  /// not the Scan.
  ///
  /// The next time this tab is visible, we will force relaunching the camera.
  bool pendingResume = false;

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
    return Consumer<BottomNavigationTab>(
      builder: (BuildContext context, BottomNavigationTab tab, Widget? child) {
        if (pendingResume &&
            tab == BottomNavigationTab.Scan &&
            Navigator.of(context).canPop()) {
          pendingResume = false;
          _onResumeImageStream();
        }

        return child!;
      },
      // [_startLiveFeed] is called both with [onResume] and [onPause] to cover
      // all entry points
      child: LifeCycleManager(
        onStart: _startLiveFeed,
        onResume: _onResumeImageStream,
        onVisible: () => _onResumeImageStream(forceStartPreview: true),
        onPause: _onPauseImageStream,
        onInvisible: _onPauseImageStream,
        child: _buildScannerWidget(),
      ),
    );
  }

  Widget _buildScannerWidget() {
    // Showing a black scanner background when the camera is not initialized
    if (!isCameraInitialized) {
      return const SizedBox.expand(
        child: ColoredBox(
          color: Colors.black,
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _computePreviewScale(constraints);

        return Transform.scale(
          scale: _previewScale,
          child: Center(
            key: ValueKey<bool>(stoppingCamera),
            child: CameraPreview(
              _controller!,
            ),
          ),
        );
      },
    );
  }

  void _computePreviewScale(BoxConstraints constraints) {
    // Only recompute if necessary
    if (_contentConstraints == constraints) {
      return;
    }

    final Size size = constraints.biggest;

    final double previewWidth;
    final double previewHeight;

    _previewScale = size.aspectRatio * _controller!.value.aspectRatio;

    if (_previewScale < 1.0) {
      // To prevent scaling down, invert the value
      _previewScale = 1.0 / _previewScale;
    } else if (_previewScale == 1.0) {
      // Same aspect ratio, but may still require scale up / down
      if (_camera?.sensorOrientation == 90) {
        previewWidth = _controller!.value.previewSize!.height;
        previewHeight = _controller!.value.previewSize!.width;
      } else {
        previewWidth = _controller!.value.previewSize!.width;
        previewHeight = _controller!.value.previewSize!.height;
      }

      _previewScale = math.max(
        size.width / previewWidth,
        size.height / previewHeight,
      );
    }

    _contentConstraints = constraints;
  }

  bool get isCameraInitialized => _controller?.isInitialized == true;

  Future<void> _startLiveFeed() async {
    if (_camera == null) {
      return;
    } else if (_controller != null) {
      return _onResumeImageStream();
    }

    stoppingCamera = false;

    // If the controller is initialized update the UI.
    _barcodeDecoder ??= MLKitScanDecoder(
      camera: _camera!,
      scanMode: DevModeScanModeExtension.fromIndex(
        _userPreferences.getDevModeIndex(
          UserPreferencesDevMode.userPreferencesEnumScanMode,
        ),
      ),
    );

    CameraHelper.initController(
      SmoothCameraController(
        _camera!,
        _userPreferences.useVeryHighResolutionPreset
            ? ResolutionPreset.veryHigh
            : ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420,
      ),
    );

    _controller!.addListener(_cameraListener);

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

          try {
            final List<String?>? res =
                await _barcodeDecoder?.processImage(image);

            _averageProcessingTime.add(
              DateTime.now().difference(start).inMilliseconds,
            );

            return res;
          } catch (err) {
            // Isolate is stopped
            return <String>[];
          }
        })
        .where(
          (List<String?>? barcodes) => barcodes?.isNotEmpty == true,
        )
        .cast<List<String>>()
        .listen(_onNewBarcodeDetected);

    try {
      await _controller?.init(
        focusMode: FocusMode.auto,
        focusPoint: _focusPoint,
        deviceOrientation: DeviceOrientation.portraitUp,
        onAvailable: (CameraImage image) => _subject.add(image),
      );
    } on CameraException catch (e) {
      if (kDebugMode) {
        // TODO(M123): Show error message
        debugPrint(e.toString());
      }
    } on FlutterError catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }

    _redrawScreen();
  }

  Future<void> _onNewBarcodeDetected(List<String> barcodes) async {
    for (final String barcode in barcodes) {
      if (await _model.onScan(barcode)) {
        // Both are Future methods, but it doesn't matter to wait here
        HapticFeedback.lightImpact();

        if (_userPreferences.playCameraSound) {
          _musicPlayer.play(
            'beep.ogg',
            mode: PlayerMode.LOW_LATENCY,
            volume: 0.5,
          );
        }
        _userPreferences.setFirstScanAchieved();
      }
    }
  }

  void _cameraListener() {
    _redrawScreen();

    if (_controller?.value.hasError == true) {
      // May happen if another application claims the camera
      // In that case, we have to destroy everything
      if (_controller!.value.isClosed) {
        _stopImageStream();
      } else {
        // TODO(M123): Handle errors better
        debugPrint(_controller!.value.errorDescription);
      }
    }
  }

  Future<void> _onPauseImageStream() async {
    if (stoppingCamera) {
      return;
    }

    _streamSubscription?.pause();
    await _controller?.pausePreview();
  }

  Future<void> _onResumeImageStream({bool forceStartPreview = false}) async {
    if (stoppingCamera ||
        (!forceStartPreview && ScreenVisibilityDetector.invisible(context))) {
      return;
    }

    final BottomNavigationTab tab = Provider.of<BottomNavigationTab>(
      context,
      listen: false,
    );

    // On visibility == true, may call us, but we have to ensure that this tab
    // is visible AND displays the camera (canPop returns false in that case)
    if (tab != BottomNavigationTab.Scan || Navigator.of(context).canPop()) {
      pendingResume = _controller?.isInitialized != true;
      return;
    }

    // Relaunch the controller if it was destroyed in background
    if (_controller?.isInitialized != true) {
      if (_controller?.isBeingInitialized == true) {
        // Just wait
        return;
      }
      return _stopImageStream();
    }

    if (_streamSubscription?.isPaused == true) {
      _streamSubscription!.resume();
    }

    await _controller?.resumePreviewIfNecessary();
    stoppingCamera = false;
  }

  Future<void> _stopImageStream() async {
    if (stoppingCamera) {
      return;
    }

    stoppingCamera = true;
    await _controller?.pausePreview();

    _redrawScreen();

    _controller?.removeListener(_cameraListener);
    await _streamSubscription?.cancel();

    await _controller?.dispose();
    await _barcodeDecoder?.dispose();
    CameraHelper.destroyControllerInstance();

    _barcodeDecoder = null;

    stoppingCamera = false;
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

      // Force redraw screen (a post frame should never be triggered otherwise)
      setStateSafe(() {});

      SchedulerBinding.instance.addPostFrameCallback((_) {
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
    _stopImageStream();
    _musicPlayer.clearAll();
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

  SmoothCameraController? get _controller => CameraHelper.controller;

  @override
  String get traceTitle => 'ml_kit_scan_page';
}
