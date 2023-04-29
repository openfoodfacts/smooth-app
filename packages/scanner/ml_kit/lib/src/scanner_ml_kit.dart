import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Scanner implementation using ML Kit
class ScannerMLKit extends Scanner {
  const ScannerMLKit();

  @override
  String getType() => 'ML Kit';

  @override
  Widget getScanner({
    required Future<bool> Function(String) onScan,
    required Future<void> Function() hapticFeedback,
    required Function(BuildContext)? onCameraFlashError,
    required Function(String msg, String category,
            {int? eventValue, String? barcode})
        trackCustomEvent,
    required bool hasMoreThanOneCamera,
  }) {
    return _SmoothBarcodeScannerMLKit(
      onScan: onScan,
      hapticFeedback: hapticFeedback,
      trackCustomEvent: trackCustomEvent,
      onCameraFlashError: onCameraFlashError,
      hasMoreThanOneCamera: hasMoreThanOneCamera,
    );
  }
}

/// Barcode scanner based on MLKit.
class _SmoothBarcodeScannerMLKit extends StatefulWidget {
  const _SmoothBarcodeScannerMLKit({
    required this.onScan,
    required this.hapticFeedback,
    required this.trackCustomEvent,
    required this.onCameraFlashError,
    required this.hasMoreThanOneCamera,
  });

  final Future<bool> Function(String) onScan;
  final Future<void> Function() hapticFeedback;

  final Function(String msg, String category,
      {int? eventValue, String? barcode}) trackCustomEvent;
  final Function(BuildContext)? onCameraFlashError;
  final bool hasMoreThanOneCamera;

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

  bool get _showFlipCameraButton => widget.hasMoreThanOneCamera;

  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
    formats: _barcodeFormats,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 250,
    // to be raised in order to avoid crashes
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
      widget.trackCustomEvent(
          Scanner.ANALYTICS_STRANGE_RESTART, Scanner.ANALYTICS_CATEGORY);
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
      widget.trackCustomEvent(
          Scanner.ANALYTICS_STRANGE_RESTOP, Scanner.ANALYTICS_CATEGORY);
    }
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: const ValueKey<String>('VisibilityDetector'),
        onVisibilityChanged: (final VisibilityInfo info) async {
          if (info.visibleBounds.height > 0.0) {
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
                          widget.hapticFeedback.call();
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
                          return const SizedBox.shrink();
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
                            widget.hapticFeedback.call();

                            try {
                              await _controller.toggleTorch();
                            } catch (err) {
                              widget.onCameraFlashError?.call(context);
                            }
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
