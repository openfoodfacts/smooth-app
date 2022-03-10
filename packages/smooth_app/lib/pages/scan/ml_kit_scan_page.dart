import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_barcode_scanner/google_ml_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/main.dart';
import 'package:smooth_app/pages/scan/abstract_camera_image_getter.dart';
import 'package:smooth_app/pages/scan/camera_image_cropper.dart';
import 'package:smooth_app/pages/scan/camera_image_full_getter.dart';
import 'package:smooth_app/pages/scan/lifecycle_manager.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';

class MLKitScannerPage extends StatefulWidget {
  const MLKitScannerPage({Key? key}) : super(key: key);

  @override
  MLKitScannerPageState createState() => MLKitScannerPageState();
}

class MLKitScannerPageState extends State<MLKitScannerPage> {
  static const int _SKIPPED_FRAMES = 10;
  BarcodeScanner? barcodeScanner;
  CameraLensDirection cameraLensDirection = CameraLensDirection.back;
  late ContinuousScanModel _model;
  late UserPreferences _userPreferences;
  CameraController? _controller;
  int _cameraIndex = 0;
  bool isBusy = false;
  //Used when rebuilding to stop the camera
  bool stoppingCamera = false;
  //We don't scan every image for performance reasons
  int frameCounter = 0;

  @override
  void initState() {
    super.initState();

    // Find the most relevant camera to use if none of these criteria are met,
    // the default value of [_cameraIndex] will be used to select the first
    // camera in the global cameras list.
    // if non matching is found we fall back to the first in the list
    // initValue of [_cameraIndex]
    if (cameras.any(
      (CameraDescription element) =>
          element.lensDirection == cameraLensDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((CameraDescription element) =>
            element.lensDirection == cameraLensDirection &&
            element.sensorOrientation == 90),
      );
    } else if (cameras.any((CameraDescription element) =>
        element.lensDirection == cameraLensDirection)) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere(
          (CameraDescription element) =>
              element.lensDirection == cameraLensDirection,
        ),
      );
    }

    _startLiveFeed();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model = context.watch<ContinuousScanModel>();
    _userPreferences = context.watch<UserPreferences>();
    return LifeCycleManager(
      onResume: _startLiveFeed,
      onPause: _stopImageStream,
      child: _buildScannerWidget(),
    );
  }

  Widget _buildScannerWidget() {
    // Showing the black scanner background + the icon when the scanner is
    // loading or stopped
    if (_controller == null ||
        _controller!.value.isInitialized == false ||
        stoppingCamera ||
        _controller!.value.isPreviewPaused ||
        !_controller!.value.isStreamingImages) {
      return Container();
    }

    final Size size = MediaQuery.of(context).size;
    // From: https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched/61487358#61487358:
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    double scale = size.aspectRatio * _controller!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) {
      scale = 1 / scale;
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

  Future<void> _startLiveFeed() async {
    if (_controller != null) {
      return;
    }

    barcodeScanner = GoogleMlKit.vision.barcodeScanner();

    stoppingCamera = false;
    final CameraDescription camera = cameras[_cameraIndex];

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // If the controller is initialized update the UI.
    _controller?.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (_controller!.value.hasError) {
        // TODO(M123): Handle errors better
        debugPrint(_controller!.value.errorDescription);
      }
    });

    try {
      await _controller?.initialize();
      _controller?.setFocusMode(FocusMode.auto);
      _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      _controller?.startImageStream(_processCameraImage);
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

  Future<void> _stopImageStream() async {
    stoppingCamera = true;
    if (mounted) {
      setState(() {});
    }
    await _controller?.dispose();
    barcodeScanner?.close();
    barcodeScanner = null;
    _controller?.removeListener(() {});
    _controller = null;
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
        getter = CameraImageFullGetter(image, cameras[_cameraIndex]);
        break;
      case DevModeScanMode.PREPROCESS_HALF_IMAGE:
      case DevModeScanMode.SCAN_HALF_IMAGE:
        getter = CameraImageCropper(
          image,
          cameras[_cameraIndex],
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
