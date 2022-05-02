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
  const MLKitScannerPage({Key? key}) : super(key: key);

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
  static const int _SKIPPED_FRAMES = 10;
  BarcodeScanner? barcodeScanner;
  late ContinuousScanModel _model;
  late UserPreferences _userPreferences;
  CameraController? _controller;
  CameraDescription? _camera;
  bool isBusy = false;

  // Used when rebuilding to stop the camera
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
    double scale = size.aspectRatio * _controller!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1.0) {
      scale = 1.0 / scale;
    }

    return Transform.scale(
      scale: scale,
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
    _controller?.addListener(cameraListener);

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

  void cameraListener() {
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

    _controller?.removeListener(cameraListener);
    await _controller?.dispose();
    await barcodeScanner?.close();

    barcodeScanner = null;
    _controller = null;

    if (mounted && ScreenVisibilityDetector.visible(context)) {
      final DateTime referentialTime = DateTime.now();

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        final int diff =
            DateTime.now().difference(referentialTime).inMilliseconds;

        // The screen is still visible, we should restart the camera
        if (diff < 60) {
          _startLiveFeed();
        }
      });
    }
  }

  @override
  void dispose() {
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
        // Half center top
        return const Offset(0.5, 0.25);
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
