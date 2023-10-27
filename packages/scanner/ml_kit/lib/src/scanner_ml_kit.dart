import 'dart:async';

import 'package:async/async.dart';
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
    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return _SmoothBarcodeScannerMLKit(
      onScan: onScan,
      hapticFeedback: hapticFeedback,
      trackCustomEvent: trackCustomEvent,
      onCameraFlashError: onCameraFlashError,
      hasMoreThanOneCamera: hasMoreThanOneCamera,
      toggleCameraModeTooltip: toggleCameraModeTooltip,
      toggleFlashModeTooltip: toggleFlashModeTooltip,
      contentPadding: contentPadding,
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
    this.toggleCameraModeTooltip,
    this.toggleFlashModeTooltip,
    this.contentPadding,
  });

  final Future<bool> Function(String) onScan;
  final Future<void> Function() hapticFeedback;

  final Function(String msg, String category,
      {int? eventValue, String? barcode}) trackCustomEvent;
  final Function(BuildContext)? onCameraFlashError;
  final bool hasMoreThanOneCamera;

  final EdgeInsetsGeometry? contentPadding;
  final String? toggleCameraModeTooltip;
  final String? toggleFlashModeTooltip;

  @override
  State<StatefulWidget> createState() => _SmoothBarcodeScannerMLKitState();
}

class _SmoothBarcodeScannerMLKitState extends State<_SmoothBarcodeScannerMLKit>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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

  static const ValueKey<String> _visibilityKey =
      ValueKey<String>('VisibilityDetector');

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

  // Stores a background operation when the screen isn't visible
  CancelableOperation<void>? _autoStopCameraOperation;
  // Stores the latest visibility value of the screen
  VisibilityInfo? _latestVisibilityInfoEvent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _stop();
    } else if (state == AppLifecycleState.resumed) {
      _autoStopCameraOperation?.cancel();
      _checkIfAppIsRestarting();
    }
  }

  void _checkIfAppIsRestarting([int retry = 0]) {
    /// When the app is resumed (from the launcher for example), the camera is
    /// always started due to the [autostart] feature and we can't
    /// prevent this behavior.
    ///
    /// To fix it, we check when the app is resumed if the camera is the
    /// visible page and if that's not the case, we wait for the camera to be
    /// initialized to stop it.
    ///
    /// Comment from @g123k: This is a very hacky way (temporary I hope) and
    /// more explanation are available on the PR:
    /// [https://github.com/openfoodfacts/smooth-app/pull/4292]
    ///
    // ignore: prefer_function_declarations_over_variables
    final Function fn = () {
      if (ScreenVisibilityDetector.invisible(context)) {
        _pauseCameraWhenInitialized();
      } else if (retry < 1) {
        // In 99% of cases, this won't happen, but if for some reason, we are
        // "considered" as visible, we will retry in a few milliseconds
        // and if we are still invisible -> force stop the camera
        _autoStopCameraOperation = CancelableOperation<void>.fromFuture(
          Future<void>.delayed(
            const Duration(milliseconds: 500),
            () => _checkIfAppIsRestarting(retry + 1),
          ),
        );
      } else if (_latestVisibilityInfoEvent?.visible == false) {
        _pauseCameraWhenInitialized();
      }
    };

    // Ensure to wait for the first frame
    if (retry == 0) {
      // ignore: avoid_dynamic_calls
      WidgetsBinding.instance.addPostFrameCallback((_) => fn.call());
    } else {
      // ignore: avoid_dynamic_calls
      scheduleMicrotask(() => fn.call());
    }
  }

  Future<void> _pauseCameraWhenInitialized() async {
    if (!mounted) {
      return;
    }

    if (_controller.isStarting) {
      _autoStopCameraOperation = CancelableOperation<void>.fromFuture(
        Future<void>.delayed(
          const Duration(milliseconds: 250),
          () => _pauseCameraWhenInitialized(),
        ),
      );
    }

    _controller.stop();
  }

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
    _autoStopCameraOperation?.cancel();
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
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (final VisibilityInfo info) async {
        _latestVisibilityInfoEvent = info;
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
          Center(
            child: SmoothBarcodeScannerVisor(
              contentPadding: widget.contentPadding,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(
                SmoothBarcodeScannerVisor.CORNER_PADDING,
              ),
              child: Row(
                mainAxisAlignment: _showFlipCameraButton
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (_showFlipCameraButton)
                    VisorButton(
                      onTap: () async {
                        widget.hapticFeedback.call();
                        await _controller.switchCamera();
                      },
                      tooltip: widget.toggleCameraModeTooltip ??
                          'Switch between back and front camera',
                      child: ValueListenableBuilder<CameraFacing>(
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
                      return VisorButton(
                        tooltip: widget.toggleFlashModeTooltip ??
                            'Turn ON or OFF the flash of the camera',
                        onTap: () async {
                          widget.hapticFeedback.call();

                          try {
                            await _controller.toggleTorch();
                          } catch (err) {
                            if (context.mounted) {
                              widget.onCameraFlashError?.call(context);
                            }
                          }
                        },
                        child: ValueListenableBuilder<TorchState>(
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoStopCameraOperation?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
