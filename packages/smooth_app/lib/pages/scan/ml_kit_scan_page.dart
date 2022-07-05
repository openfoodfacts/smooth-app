import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
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
import 'package:smooth_app/pages/scan/camera_image_preview.dart';
import 'package:smooth_app/pages/scan/lifecycle_manager.dart';
import 'package:smooth_app/pages/scan/mkit_scan_helper.dart';
import 'package:smooth_app/pages/scan/scan_visor.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/widgets/lifecycle_aware_widget.dart';
import 'package:smooth_app/widgets/screen_visibility.dart';

class MLKitScannerPage extends LifecycleAwareStatefulWidget {
  const MLKitScannerPage({
    super.key,
  });

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

  /// Audio player to play the beep sound on scan
  /// This attribute is only initialized when a camera is available AND the
  /// setting is set to ON
  AudioPlayer? _musicPlayer;

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

    if (_camera != null) {
      _subject = PublishSubject<CameraImage>();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (mounted) {
      _model = context.watch<ContinuousScanModel>();
      _userPreferences = context.watch<UserPreferences>();
    }

    // Relaunch the feed after a hot reload
    if (_isScreenVisible()) {
      if (_controller == null) {
        _startLiveFeed();
      } else {
        _controller!.updateFocusPointAlgorithm(
          _userPreferences.cameraFocusPointAlgorithm,
        );
      }
    }
  }

  @override
  String get traceTitle => 'ml_kit_scan_page';

  @override
  String get traceName => 'Opened ml_kit_scan_page';

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationTab>(
      builder: (BuildContext context, BottomNavigationTab tab, Widget? child) {
        if (pendingResume && _isScreenVisible(tab: tab)) {
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

  /// Returns if the current tab is visible AND the scanner is also visible
  /// (= the first element = canPop == false)
  bool _isScreenVisible({BottomNavigationTab? tab}) {
    return (tab ?? Provider.of<BottomNavigationTab>(context, listen: false)) ==
            BottomNavigationTab.Scan &&
        !Navigator.of(context).canPop();
  }

  Widget _buildScannerWidget() {
    // Showing a black scanner background when the camera is not initialized
    if (!isCameraReady) {
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
            child: const SmoothCameraStreamPreview(),
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

  bool get isCameraReady => _controller?.canShowPreview == true;

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
      scanMode: DevModeScanMode.fromIndex(
        _userPreferences.getDevModeIndex(
          UserPreferencesDevMode.userPreferencesEnumScanMode,
        ),
      ),
    );

    CameraHelper.initController(
      SmoothCameraController(
        _userPreferences,
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
      final _FocusPoint point = _focusPoint;

      await _controller?.init(
        focusMode: FocusMode.auto,
        focusPoint: point.offset,
        deviceOrientation: DeviceOrientation.portraitUp,
        onAvailable: (CameraImage image) => _subject.add(image),
      );

      // If the Widget tree isn't ready, wait for the first frame
      if (!point.precise) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller?.setFocusPointTo(
            _focusPoint.offset,
            _userPreferences.cameraFocusPointAlgorithm,
          );
        });
      }
    } on CameraException catch (e) {
      Logs.d('On camera error', ex: e);

      // The camera may not be ready. Wait a short time and try again.
      return _stopImageStream();
    } on FlutterError catch (e) {
      Logs.d('On camera (Flutter part) error', ex: e);
    }

    _redrawScreen();
  }

  Future<void> _onNewBarcodeDetected(List<String> barcodes) async {
    for (final String barcode in barcodes) {
      if (await _model.onScan(barcode)) {
        // Both are Future methods, but it doesn't matter to wait here
        HapticFeedback.lightImpact();

        if (_userPreferences.playCameraSound) {
          await _initSoundManagerIfNecessary();
          await _musicPlayer!.stop();
          await _musicPlayer!.resume();
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
        Logs.e(
          'On camera controller error : ${_controller!.value.errorDescription}',
        );
      }
    }
  }

  Future<void> _onPauseImageStream() async {
    if (stoppingCamera) {
      return;
    }

    if (_controller != null &&
        _controller!.isPauseResumePreviewSupported != true) {
      await _stopImageStream(autoRestart: false);
    } else {
      _streamSubscription?.pause();
      await _controller?.pausePreview();
    }

    await _disposeSoundManager();
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

    if (_controller?.isPauseResumePreviewSupported == true) {
      try {
        await _controller?.resumePreviewIfNecessary();
      } on CameraException catch (_) {
        // Dart Controller is OK, but native part is KO
        return _stopImageStream();
      }
    }
    stoppingCamera = false;
  }

  Future<void> _stopImageStream({bool autoRestart = true}) async {
    if (stoppingCamera) {
      return;
    }

    stoppingCamera = true;

    if (_controller?.isPauseResumePreviewSupported == true) {
      await _controller?.pausePreview();
    }

    _redrawScreen();

    _controller?.removeListener(_cameraListener);

    // Don't wait for the controller to be disposed,
    // a new one will be created in parallel
    _controller?.dispose();
    CameraHelper.destroyControllerInstance();

    await _streamSubscription?.cancel();

    await _barcodeDecoder?.dispose();
    _barcodeDecoder = null;

    stoppingCamera = false;

    if (autoRestart) {
      _restartCameraIfNecessary();
    }
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
        if (diff < _minPostFrameCallbackDelay && _isScreenVisible()) {
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

  /// Only initialize the "beep" player when needed
  /// (at least one camera available + settings set to ON)
  Future<void> _initSoundManagerIfNecessary() async {
    if (_musicPlayer != null) {
      return;
    }

    _musicPlayer = AudioPlayer(playerId: '1');
    await _musicPlayer!.setSourceAsset('audio/beep.ogg');
    await _musicPlayer!.setPlayerMode(PlayerMode.lowLatency);
    await _musicPlayer!.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notificationEvent,
          audioFocus: AndroidAudioFocus.gainTransientExclusive,
        ),
        iOS: AudioContextIOS(
          defaultToSpeaker: false,
          category: AVAudioSessionCategory.soloAmbient,
          options: <AVAudioSessionOptions>[
            AVAudioSessionOptions.mixWithOthers,
          ],
        ),
      ),
    );
  }

  Future<void> _disposeSoundManager() async {
    await _musicPlayer?.release();
    await _musicPlayer?.dispose();
    _musicPlayer = null;
  }

  @override
  void dispose() {
    // /!\ This call is a Future, which may leads to some issues.
    // This should be handled by [_restartCameraIfNecessary]
    _stopImageStream();
    _disposeSoundManager();
    super.dispose();
  }

  /// Whatever the scan mode is, we always want the focus point to be on
  /// the middle of the [ScannerVisorWidget]
  _FocusPoint get _focusPoint {
    final double? preciseY;

    if (mounted) {
      final GlobalKey<ScannerVisorWidgetState> key =
          Provider.of<GlobalKey<ScannerVisorWidgetState>>(context,
              listen: false);

      final Offset? visorOffset =
          (key.currentContext?.findRenderObject() as RenderBox?)
              ?.localToGlobal(Offset.zero);

      if (visorOffset != null) {
        preciseY = (visorOffset.dy +
                (ScannerVisorWidget.getSize(context).height) / 2) /
            MediaQuery.of(context).size.height;
      } else {
        preciseY = null;
      }
    } else {
      preciseY = null;
    }

    return _FocusPoint(
      offset: Offset(0.5, preciseY ?? 0.25 / _previewScale),
      precise: preciseY != null,
    );
  }

  SmoothCameraController? get _controller => CameraHelper.controller;
}

/// Provides the position to the center of the visor
/// [precise] is [true] when the computation is based on the Widget coordinates
class _FocusPoint {
  _FocusPoint({
    required this.offset,
    required this.precise,
  });

  final Offset offset;
  final bool precise;
}
