import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/scan/lifecycle_manager.dart';

class ContinuousScanPage extends StatefulWidget {
  const ContinuousScanPage();

  @override
  State<ContinuousScanPage> createState() => _ContinuousScanPageState();
}

class _ContinuousScanPageState extends State<ContinuousScanPage> {
  final GlobalKey _scannerViewKey = GlobalKey(debugLabel: 'qr Barcode Scanner');
  late ContinuousScanModel _model;
  QRViewController? _controller;

  @override
  Widget build(BuildContext context) {
    _model = context.watch<ContinuousScanModel>();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double carouselHeight =
            constraints.maxHeight / 1.81; // roughly 55% of the available height
        final double viewFinderBottomOffset = carouselHeight / 2.0;

        return LifeCycleManager(
          onResume: _resumeLiveFeed,
          onPause: _stopLiveFeed,
          child: QRView(
            overlay: QrScannerOverlayShape(
              // We use [SmoothViewFinder] instead of the overlay.
              overlayColor: Colors.transparent,
              // This offset adjusts the scanning area on iOS.
              cutOutBottomOffset: viewFinderBottomOffset,
            ),
            key: _scannerViewKey,
            onQRViewCreated: setupScanner,
          ),
        );
      },
    );
  }

  void setupScanner(QRViewController controller) {
    _controller = controller;
    _controller?.scannedDataStream
        .listen((Barcode barcode) => _model.onScan(barcode.code));
  }

  //Used when navigating away from the QRView itself
  void _stopLiveFeed() => _controller?.stopCamera();

  //Used when navigating back to the QRView
  void _resumeLiveFeed() => _controller?.resumeCamera();
}
