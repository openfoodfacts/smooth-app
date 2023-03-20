import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/scan/scan_header.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/screen_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Barcode scanner based on ZXing.
class SmoothBarcodeScannerZXing extends StatefulWidget {
  const SmoothBarcodeScannerZXing(this.onScan);

  final Future<bool> Function(String) onScan;

  @override
  State<StatefulWidget> createState() => _SmoothBarcodeScannerZXingState();
}

class _SmoothBarcodeScannerZXingState extends State<SmoothBarcodeScannerZXing> {
  // just 1D formats and ios supported
  static const List<BarcodeFormat> _barcodeFormats = <BarcodeFormat>[
    BarcodeFormat.code39,
    BarcodeFormat.code93,
    BarcodeFormat.code128,
    BarcodeFormat.ean8,
    BarcodeFormat.ean13,
    BarcodeFormat.itf,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
  ];

  bool _visible = false;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  bool get _showFlipCameraButton => CameraHelper.hasMoreThanOneCamera;

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: const ValueKey<String>('VisibilityDetector'),
        onVisibilityChanged: (final VisibilityInfo info) {
          if (info.visible) {
            if (_visible) {
              return;
            }
            _visible = true;
            _controller?.resumeCamera();
            return;
          }
          if (!_visible) {
            return;
          }
          _visible = false;
          _controller?.pauseCamera();
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Stack(
            children: <Widget>[
              QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutWidth: constraints.maxWidth - 2 * MINIMUM_TOUCH_SIZE,
                  cutOutHeight: constraints.maxHeight,
                ),
                formatsAllowed: _barcodeFormats,
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'ZXing',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: ScanHeader(),
              ),
              Center(
                child: SvgPicture.asset(
                  'assets/icons/visor_icon.svg',
                  package: AppHelper.APP_PACKAGE,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: _showFlipCameraButton
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (_showFlipCameraButton)
                      IconButton(
                        icon: Icon(ConstantIcons.instance.getCameraFlip()),
                        color: Colors.white,
                        onPressed: () async {
                          SmoothHapticFeedback.click();
                          await _controller?.flipCamera();
                          setState(() {});
                        },
                      ),
                    FutureBuilder<bool?>(
                      future: _controller?.getFlashStatus(),
                      builder: (_, final AsyncSnapshot<bool?> snapshot) {
                        final bool? flashOn = snapshot.data;
                        if (flashOn == null) {
                          return EMPTY_WIDGET;
                        }
                        return IconButton(
                          icon:
                              Icon(flashOn ? Icons.flash_on : Icons.flash_off),
                          color: Colors.white,
                          onPressed: () async {
                            SmoothHapticFeedback.click();
                            await _controller?.toggleFlash();
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  void _onQRViewCreated(final QRViewController controller) {
    setState(() => _controller = controller);
    controller.scannedDataStream.listen(
      (final Barcode scanData) {
        final String? barcode = scanData.code;
        if (barcode != null) {
          widget.onScan(barcode);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
