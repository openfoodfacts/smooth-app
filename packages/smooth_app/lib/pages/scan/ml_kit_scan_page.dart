import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_ml_barcode_scanner/google_ml_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/scan/scan_page_helper.dart'
    as scan_page_helper;
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../main.dart';

class MLKitScannerPage extends StatefulWidget {
  const MLKitScannerPage({Key? key}) : super(key: key);

  @override
  MLKitScannerPageState createState() => MLKitScannerPageState();
}

class MLKitScannerPageState extends State<MLKitScannerPage> {
  BarcodeScanner? barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  late ContinuousScanModel _model;
  CameraController? _controller;
  int _cameraIndex = 0;
  CameraLensDirection cameraLensDirection = CameraLensDirection.back;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();

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
    _stopLiveFeed();
    _disposeLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VisibilityDetector(
        key: const Key('VisibilityDetector ML-Kit'),
        onVisibilityChanged: (VisibilityInfo visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0.0) {
            _stopLiveFeed();
          } else {
            _startLiveFeed();
          }
        },
        child: _liveFeedBody(),
      ),
    );
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final Size size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    double scale = size.aspectRatio * _controller!.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) {
      scale = 1 / scale;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _model = context.watch<ContinuousScanModel>();
        final Size screenSize = MediaQuery.of(context).size;
        final Size scannerSize = Size(
          screenSize.width * 0.6,
          screenSize.width * 0.33,
        );
        final double carouselHeight =
            constraints.maxHeight / 1.81; // roughly 55% of the available height
        final double buttonRowHeight =
            scan_page_helper.areButtonsRendered(_model) ? 48 : 0;
        final double availableScanHeight =
            constraints.maxHeight - carouselHeight - buttonRowHeight;
        // Padding for the qr code scanner. This ensures the scanner has equal spacing between buttons and carousel.
        final EdgeInsets qrScannerPadding = EdgeInsets.only(
            top: (availableScanHeight - scannerSize.height) / 2 +
                buttonRowHeight);

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: Padding(
                padding: qrScannerPadding,
                child: SvgPicture.asset(
                  'assets/actions/scanner_alt_2.svg',
                  width: 60.0,
                  height: 6,
                  color: Colors.white,
                ),
              ),
            ),
            SmoothRevealAnimation(
              delay: 400,
              startOffset: Offset.zero,
              animationCurve: Curves.easeInOutBack,
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
            SmoothRevealAnimation(
              delay: 400,
              startOffset: const Offset(0.0, 0.1),
              animationCurve: Curves.easeInOutBack,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: qrScannerPadding,
                    child: SmoothViewFinder(
                      boxSize: scannerSize,
                      lineLength: screenSize.width * 0.8,
                    ),
                  ),
                ],
              ),
            ),
            SmoothRevealAnimation(
              delay: 400,
              startOffset: const Offset(0.0, -0.1),
              animationCurve: Curves.easeInOutBack,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  scan_page_helper.buildButtonsRow(context, _model),
                  const Spacer(),
                  SmoothProductCarousel(
                    showSearchCard: true,
                    height: carouselHeight,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startLiveFeed() async {
    final CameraDescription camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.setFocusMode(FocusMode.auto);
      _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future<void> _stopLiveFeed() async {
    await _controller?.stopImageStream();
    _controller = null;
  }

  Future<void> _disposeLiveFeed() async {
    await _controller?.dispose();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final Uint8List bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final CameraDescription camera = cameras[_cameraIndex];
    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(
              int.parse(image.format.raw.toString()),
            ) ??
            InputImageFormat.NV21;

    final List<InputImagePlaneMetadata> planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final InputImageData inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final InputImage inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (barcodeScanner == null || isBusy) {
      return;
    }

    isBusy = true;

    final List<Barcode> barcodes =
        await barcodeScanner!.processImage(inputImage);

    //ignore: avoid_function_literals_in_foreach_calls
    barcodes.forEach((Barcode barcode) {
      _model.onScanMLKit(barcode);
    });

    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
