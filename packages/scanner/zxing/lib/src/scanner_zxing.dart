import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:scanner_shared/app_store_shared.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Empty implementation for an [AppStore]
class ScannerZXing extends Scanner {
  const ScannerZXing({
    required this.hapticFeedback,
    required this.hasMoreThanOneCamera,
    required this.smoothBarcodeScannerVisor,
    required this.scanHeader,
  });

  final Future<void> Function() hapticFeedback;
  final bool hasMoreThanOneCamera;
  final Widget smoothBarcodeScannerVisor;
  final Widget scanHeader;

  @override
  Widget getScanner(Future<bool> Function(String) onScan) {
    return _SmoothBarcodeScannerZXing(
      onScan: onScan,
      hapticFeedback: hapticFeedback,
      hasMoreThanOneCamera: hasMoreThanOneCamera,
      smoothBarcodeScannerVisor: smoothBarcodeScannerVisor,
      scanHeader: scanHeader,
    );
  }
}

/// Barcode scanner based on ZXing.
class _SmoothBarcodeScannerZXing extends StatefulWidget {
  const _SmoothBarcodeScannerZXing({
    required this.onScan,
    required this.hapticFeedback,
    required this.hasMoreThanOneCamera,
    required this.smoothBarcodeScannerVisor,
    required this.scanHeader,
  });

  final Future<bool> Function(String) onScan;
  final Future<void> Function() hapticFeedback;
  final bool hasMoreThanOneCamera;
  final Widget smoothBarcodeScannerVisor;
  final Widget scanHeader;

  @override
  State<StatefulWidget> createState() => _SmoothBarcodeScannerZXingState();
}

class _SmoothBarcodeScannerZXingState
    extends State<_SmoothBarcodeScannerZXing> {
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

  static const double _cornerPadding = 26;

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

  bool get _showFlipCameraButton => widget.hasMoreThanOneCamera;

  static bool _isApple() =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  IconData getCameraFlip() =>
      _isApple() ? Icons.flip_camera_ios : Icons.flip_camera_android;

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: const ValueKey<String>('VisibilityDetector'),
        onVisibilityChanged: (final VisibilityInfo info) {
          if (info.visibleBounds.height > 0.0) {
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
        child: Stack(
          children: <Widget>[
            QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
              formatsAllowed: _barcodeFormats,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(_cornerPadding),
                child: widget.smoothBarcodeScannerVisor,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: widget.scanHeader,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(_cornerPadding),
                child: Row(
                  mainAxisAlignment: _showFlipCameraButton
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (_showFlipCameraButton)
                      IconButton(
                        icon: Icon(getCameraFlip()),
                        color: Colors.white,
                        onPressed: () async {
                          widget.hapticFeedback.call();
                          await _controller?.flipCamera();
                          setState(() {});
                        },
                      ),
                    FutureBuilder<bool?>(
                      future: _controller?.getFlashStatus(),
                      builder: (_, final AsyncSnapshot<bool?> snapshot) {
                        final bool? flashOn = snapshot.data;
                        if (flashOn == null) {
                          return const SizedBox.shrink();
                        }
                        return IconButton(
                          icon:
                              Icon(flashOn ? Icons.flash_on : Icons.flash_off),
                          color: Colors.white,
                          onPressed: () async {
                            widget.hapticFeedback.call();
                            await _controller?.toggleFlash();
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
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
