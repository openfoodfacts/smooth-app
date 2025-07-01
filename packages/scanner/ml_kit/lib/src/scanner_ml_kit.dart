import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:scanner_ml_kit/src/mobile_scanner_controller.dart';
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
    required Function(
      String msg,
      String category, {
      int? eventValue,
      String? barcode,
    })
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

  final Function(
    String msg,
    String category, {
    int? eventValue,
    String? barcode,
  })
  trackCustomEvent;
  final Function(BuildContext)? onCameraFlashError;
  final bool hasMoreThanOneCamera;

  final EdgeInsetsGeometry? contentPadding;
  final String? toggleCameraModeTooltip;
  final String? toggleFlashModeTooltip;

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

  static const ValueKey<String> _visibilityKey = ValueKey<String>(
    'VisibilityDetector',
  );

  late CustomScannerController _cameraController;
  late final AppLifecycleListener _lifecycleListener;
  bool _screenVisible = false;

  @override
  void initState() {
    super.initState();

    _cameraController = CustomScannerController(
      controller: MobileScannerController(
        autoStart: false,
        torchEnabled: false,
        formats: _barcodeFormats,
        facing: CameraFacing.back,
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 250,
        // to be raised in order to avoid crashes
        returnImage: false,
      ),
    );
    _lifecycleListener = AppLifecycleListener(
      onPause: _onPause,
      onResume: _onResume,
    );
  }

  Future<void> _onResume() async {
    if (_screenVisible) {
      return _cameraController.start();
    }
  }

  Future<void> _onPause() => _cameraController.stop();

  @override
  Widget build(BuildContext context) {
    return Provider<CustomScannerController>.value(
      value: _cameraController,
      child: VisibilityDetector(
        key: _visibilityKey,
        onVisibilityChanged: (final VisibilityInfo info) async {
          _screenVisible = info.visibleFraction > 0;
          _onScreenVisibilityChanged(_screenVisible);
        },
        child: Stack(
          children: <Widget>[
            MobileScanner(
              controller: _cameraController.controller,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                    BuildContext context,
                    MobileScannerException error,
                    Widget? child,
                  ) => EMPTY_WIDGET,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _ToggleCameraIcon(
                      toggleCameraModeTooltip: widget.toggleCameraModeTooltip,
                      hapticFeedback: widget.hapticFeedback,
                    ),
                    _TorchIcon(
                      toggleFlashModeTooltip: widget.toggleFlashModeTooltip,
                      hapticFeedback: widget.hapticFeedback,
                      onCameraFlashError: widget.onCameraFlashError,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onScreenVisibilityChanged(bool visible) {
    if (visible) {
      _cameraController.start();
    } else {
      _cameraController.stop();
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _cameraController.dispose();
    super.dispose();
  }
}

class _TorchIcon extends StatefulWidget {
  const _TorchIcon({
    required this.hapticFeedback,
    required this.onCameraFlashError,
    this.toggleFlashModeTooltip,
  });

  final String? toggleFlashModeTooltip;
  final Future<void> Function() hapticFeedback;
  final Function(BuildContext)? onCameraFlashError;

  @override
  State<_TorchIcon> createState() => _TorchIconState();
}

class _TorchIconState extends State<_TorchIcon> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: context.watch<CustomScannerController>().hasTorchState,
      builder: (BuildContext context, bool? hasTorch, _) {
        if (hasTorch == null) {
          return EMPTY_WIDGET;
        }

        final CustomScannerController controller = context
            .watch<CustomScannerController>();
        final bool isTorchOn = controller.isTorchOn;

        return VisorButton(
          tooltip:
              widget.toggleFlashModeTooltip ??
              'Turn ON or OFF the flash of the camera',
          onTap: () async {
            widget.hapticFeedback.call();

            try {
              context.read<CustomScannerController>().toggleTorch();
            } catch (err) {
              if (context.mounted) {
                widget.onCameraFlashError?.call(context);
              }
            }
          },
          child: switch (isTorchOn) {
            true => const Icon(Icons.flash_off, color: Colors.white),
            false => const Icon(Icons.flash_on, color: Colors.white),
          },
        );
      },
    );
  }
}

class _ToggleCameraIcon extends StatelessWidget {
  const _ToggleCameraIcon({
    required this.hapticFeedback,
    this.toggleCameraModeTooltip,
  });

  final Future<void> Function() hapticFeedback;
  final String? toggleCameraModeTooltip;

  @override
  Widget build(BuildContext context) {
    final CustomScannerController controller = context
        .watch<CustomScannerController>();

    return ValueListenableBuilder<int>(
      valueListenable: controller.availableCameras,
      builder: (BuildContext context, int cameras, _) {
        if (cameras <= 1) {
          return EMPTY_WIDGET;
        }

        return VisorButton(
          onTap: () async {
            hapticFeedback.call();
            controller.toggleCamera();
          },
          tooltip:
              toggleCameraModeTooltip ?? 'Switch between back and front camera',
          child: ValueListenableBuilder<CameraFacing>(
            valueListenable: controller.cameraFacing,
            builder: (BuildContext context, CameraFacing state, Widget? child) {
              switch (state) {
                case CameraFacing.front:
                  return const Icon(Icons.camera_front);
                case CameraFacing.back:
                  return const Icon(Icons.camera_rear);
              }
            },
          ),
        );
      },
    );
  }
}
