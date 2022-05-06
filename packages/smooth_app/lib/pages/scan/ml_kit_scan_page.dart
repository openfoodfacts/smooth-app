import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_barcode_scanner/google_ml_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/pages/scan/abstract_camera_image_getter.dart';
import 'package:smooth_app/pages/scan/camera_image_cropper.dart';
import 'package:smooth_app/pages/scan/camera_image_full_getter.dart';
import 'package:smooth_app/pages/scan/lifecycle_manager.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';
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

class _MLKitScannerPageContent extends StatefulWidget {
  const _MLKitScannerPageContent({Key? key}) : super(key: key);

  @override
  MLKitScannerPageState createState() => MLKitScannerPageState();
}

class MLKitScannerPageState extends State<_MLKitScannerPageContent> {
  /// If the camera is being closed (when [stoppingCamera] == true) and this
  /// Widget is visible again, we add a post frame callback to detect if the
  /// Widget is still visible
  ///
  /// If the time took by the "post frame callback" is less than this duration,
  /// we considered, that the camera should be reinitialized
  ///
  /// On a 60Hz display, one frame =~ 16 ms => 100 ms =~ 6 frames.
  static const int _postFrameCallBackMinDelay = 100; // in milliseconds

  static const int _SKIPPED_FRAMES = 10;
  BarcodeScanner? barcodeScanner;
  late ContinuousScanModel _model;
  late UserPreferences _userPreferences;
  CameraController? _controller;
  CameraDescription? _camera;
  bool isBusy = false;
  double _previewScale = 1.0;

  /// Flag used to prevent the camera from being initialized.
  /// When set to [false], [_startLiveStream] can be called.
  bool stoppingCamera = false;

  //We don't scan every image for performance reasons
  int frameCounter = 0;

  @override
  void initState() {
    super.initState();
    _camera = CameraHelper.findBestCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Relaunch the feed after a hot reload
    if (_controller == null) {
      _startLiveFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    _model = context.watch<ContinuousScanModel>();
    _userPreferences = context.watch<UserPreferences>();

    // [_startLiveFeed] is called both with [onResume] and [onPause] to cover
    // all entry points
    return LifeCycleManager(
      onStart: _startLiveFeed,
      onResume: _startLiveFeed,
      onPause: _stopImageStream,
      child: _buildScannerWidget(),
    );
  }

  Widget _buildScannerWidget() {
    // Showing the black scanner background + the icon when the scanner is
    // loading or stopped
    if (isCameraNotInitialized) {
      return const SizedBox();
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
      alignment: Alignment.topCenter,
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

    barcodeScanner = GoogleMlKit.vision.barcodeScanner();
    stoppingCamera = false;

    _controller = CameraController(
      _camera!,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // If the controller is initialized update the UI.
    _controller?.addListener(_cameraListener);

    try {
      await _controller?.initialize();
      await _controller?.setFocusMode(FocusMode.auto);
      await _controller?.setFocusPoint(_focusPoint);
      await _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await _controller?.startImageStream(_processCameraImage);
    } on CameraException catch (e) {
      if (kDebugMode) {
        // TODO(M123): Show error message
        debugPrint(e.toString());
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _cameraListener() {
    if (mounted) {
      setState(() {});

      if (_controller?.value.hasError == true) {
        // TODO(M123): Handle errors better
        debugPrint(_controller!.value.errorDescription);
      }
    }
  }

  Future<void> _stopImageStream() async {
    if (stoppingCamera) {
      return;
    }

    stoppingCamera = true;
    if (mounted) {
      setState(() {});
    }

    _controller?.removeListener(_cameraListener);
    await _controller?.dispose();
    await barcodeScanner?.close();

    barcodeScanner = null;
    _controller = null;

    _restartCameraIfNecessary();
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

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        final int diff =
            DateTime.now().difference(referentialTime).inMilliseconds;

        // The screen is still visible, we should restart the camera
        if (diff < _postFrameCallBackMinDelay) {
          _startLiveFeed();
        }
      });
    }
  }

  @override
  void dispose() {
    // /!\ This call is a Future, which may leads to some issues.
    // This should be handled by [_restartCameraIfNecessary]
    _stopImageStream();
    super.dispose();
  }

  // Convert the [CameraImage] to a [InputImage] and checking this for barcodes
  // with help from ML Kit
  Future<void> _processCameraImage(CameraImage image) async {
    //Only scanning every xth image, but not resetting until the current one
    //is done, so that we don't have idle time when the scanning takes longer
    // TODO(M123): Can probably be merged with isBusy + checking if we should
    // Count when ML Kit is busy
    if (frameCounter < _SKIPPED_FRAMES) {
      frameCounter++;
      return;
    }

    if (isBusy || barcodeScanner == null) {
      return;
    }
    isBusy = true;
    frameCounter = 0;

    await _scan(image);

    isBusy = false;
  }

  Offset? get _focusPoint {
    final DevModeScanMode scanMode = DevModeScanModeExtension.fromIndex(
      _userPreferences
          .getDevModeIndex(UserPreferencesDevMode.userPreferencesEnumScanMode),
    );

    switch (scanMode) {
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
      case DevModeScanMode.SCAN_HALF_IMAGE:
        // Half center top focus point

        if (_previewScale == 1.0) {
          return const Offset(0.5, 0.25);
        } else {
          // Since we use a [Alignment.topCenter] alignment for the preview, we
          // have to recompute the position of the focus point
          return Offset(0.5, 0.25 / _previewScale);
        }
      case DevModeScanMode.CAMERA_ONLY:
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
      case DevModeScanMode.SCAN_FULL_IMAGE:
      default:
        // Center
        return const Offset(0.5, 0.5);
    }
  }

  Future<void> _scan(final CameraImage image) async {
    final DevModeScanMode scanMode = DevModeScanModeExtension.fromIndex(
      _userPreferences
          .getDevModeIndex(UserPreferencesDevMode.userPreferencesEnumScanMode),
    );

    final AbstractCameraImageGetter getter;
    switch (scanMode) {
      case DevModeScanMode.CAMERA_ONLY:
        return;
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
      case DevModeScanMode.SCAN_FULL_IMAGE:
        getter = CameraImageFullGetter(image, _camera!);
        break;
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
      case DevModeScanMode.SCAN_HALF_IMAGE:
        getter = CameraImageCropper(
          image,
          _camera!,
          left01: 0,
          top01: 0,
          width01: 1,
          height01: .5,
        );
        break;
    }
    final InputImage inputImage = getter.getInputImage();

    switch (scanMode) {
      case DevModeScanMode.CAMERA_ONLY:
      case DevModeScanMode.PREPROCESS_FULL_IMAGE:
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
        return;
      case DevModeScanMode.SCAN_FULL_IMAGE:
      case DevModeScanMode.SCAN_HALF_IMAGE:
        break;
    }
    final List<Barcode> barcodes =
        await barcodeScanner!.processImage(inputImage);

    for (final Barcode barcode in barcodes) {
      _model
          .onScan(barcode.value.rawValue); // TODO(monsieurtanuki): add "await"?
    }
  }
}
