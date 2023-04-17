import 'dart:async';

import 'package:app_store_shared/app_store_shared.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/scan/scan_header.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_visor.dart';
import 'package:smooth_app/widgets/screen_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:app_store_shared/src/app_store.dart';

/// Empty implementation for an [AppStore]
class ScannerMLKit extends Scanner {
  const ScannerMLKit();


  @override
  Widget getScanner(Future<bool> Function(String) onScan){
    return _SmoothBarcodeScannerMLKit(onScan);
  }
}





/// Barcode scanner based on MLKit.
class _SmoothBarcodeScannerMLKit extends StatefulWidget {
  const _SmoothBarcodeScannerMLKit(this.onScan);

  final Future<bool> Function(String) onScan;

  @override
  State<StatefulWidget> createState() => _SmoothBarcodeScannerMLKitState();
}

class _SmoothBarcodeScannerMLKitState extends State<_SmoothBarcodeScannerMLKit>
    with SingleTickerProviderStateMixin {
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

  bool _isStarted = true;

  bool get _showFlipCameraButton => CameraHelper.hasMoreThanOneCamera;

  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
    formats: _barcodeFormats,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 250, // to be raised in order to avoid crashes
    returnImage: false,
    autoStart: true,
  );

  Future<void> _start() async {
    if (_isStarted) {
      return;
    }
    if (_controller.isStarting) {
      return;
    }
    try {
      await _controller.start();
      _isStarted = true;
    } on Exception {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.scanStrangeRestart,
      );
    }
  }

  Future<void> _stop() async {
    if (!_isStarted) {
      return;
    }
    try {
      await _controller.stop();
      _isStarted = false;
    } on Exception {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.scanStrangeRestop,
      );
    }
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: const ValueKey<String>('VisibilityDetector'),
        onVisibilityChanged: (final VisibilityInfo info) async {
          if (info.visible) {
            await _start();
          } else {
            await _stop();
          }
        },
        child: Stack(
          children: <Widget>[
            MobileScanner(
              controller: _controller,
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                MobileScannerException error,
                Widget? child,
              ) =>
                  EMPTY_WIDGET,
              onDetect: (final BarcodeCapture capture) async {
                for (final Barcode barcode in capture.barcodes) {
                  final String? string = barcode.displayValue;
                  if (string != null) {
                    await widget.onScan(string);
                  }
                }
              },
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(_cornerPadding),
                child: SmoothBarcodeScannerVisor(),
              ),
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: ScanHeader(),
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
                        color: Colors.white,
                        icon: ValueListenableBuilder<CameraFacing>(
                          valueListenable: _controller.cameraFacingState,
                          builder: (
                            BuildContext context,
                            CameraFacing state,
                            Widget? child,
                          ) {
                            switch (state) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        onPressed: () async {
                          SmoothHapticFeedback.click();
                          await _controller.switchCamera();
                        },
                      ),
                    ValueListenableBuilder<bool?>(
                      valueListenable: _controller.hasTorchState,
                      builder: (
                        BuildContext context,
                        bool? state,
                        Widget? child,
                      ) {
                        if (state != true) {
                          return EMPTY_WIDGET;
                        }
                        return IconButton(
                          color: Colors.white,
                          icon: ValueListenableBuilder<TorchState>(
                            valueListenable: _controller.torchState,
                            builder: (
                              BuildContext context,
                              TorchState state,
                              Widget? child,
                            ) {
                              switch (state) {
                                case TorchState.off:
                                  return const Icon(
                                    Icons.flash_off,
                                    color: Colors.white,
                                  );
                                case TorchState.on:
                                  return const Icon(
                                    Icons.flash_on,
                                    color: Colors.white,
                                  );
                              }
                            },
                          ),
                          onPressed: () async {
                            SmoothHapticFeedback.click();
                            await _controller.toggleTorch();
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
}

