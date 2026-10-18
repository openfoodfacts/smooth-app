import 'dart:async';

import 'package:camera/camera.dart' show FlashMode;
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Scanner implementation using ZXing
class ScannerZXing extends Scanner {
  const ScannerZXing();

  @override
  String getType() => 'ZXing';

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
    required Widget barcodeScannerIcon,
    required Widget torchOnIcon,
    required Widget torchOffIcon,
    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return _SmoothBarcodeScannerZXing(
      onScan: onScan,
      hapticFeedback: hapticFeedback,
      onCameraFlashError: onCameraFlashError,
      hasMoreThanOneCamera: hasMoreThanOneCamera,
      toggleCameraModeTooltip: toggleCameraModeTooltip,
      toggleFlashModeTooltip: toggleFlashModeTooltip,
      barcodeScannerIcon: barcodeScannerIcon,
      torchOnIcon: torchOnIcon,
      torchOffIcon: torchOffIcon,
      contentPadding: contentPadding,
    );
  }
}

/// Barcode scanner based on ZXing.
class _SmoothBarcodeScannerZXing extends StatefulWidget {
  const _SmoothBarcodeScannerZXing({
    required this.onScan,
    required this.hapticFeedback,
    required this.onCameraFlashError,
    required this.hasMoreThanOneCamera,
    required this.barcodeScannerIcon,
    required this.torchOnIcon,
    required this.torchOffIcon,
    this.toggleCameraModeTooltip,
    this.toggleFlashModeTooltip,
    this.contentPadding,
  });

  final Future<bool> Function(String) onScan;
  final Future<void> Function() hapticFeedback;
  final Function(BuildContext)? onCameraFlashError;
  final bool hasMoreThanOneCamera;

  final Widget barcodeScannerIcon;
  final Widget torchOnIcon;
  final Widget torchOffIcon;

  final EdgeInsetsGeometry? contentPadding;
  final String? toggleCameraModeTooltip;
  final String? toggleFlashModeTooltip;

  @override
  State<StatefulWidget> createState() => _SmoothBarcodeScannerZXingState();
}

class _SmoothBarcodeScannerZXingState
    extends State<_SmoothBarcodeScannerZXing> {
  static const int _formats =
      Format.code39 |
      Format.code93 |
      Format.code128 |
      Format.ean8 |
      Format.ean13 |
      Format.itf |
      Format.upca |
      Format.upce |
      // 2D formats for GS1 Sunrise 2027
      Format.dataMatrix |
      Format.qrCode;

  bool _visible = false;
  CameraLensDirection _lensDirection = CameraLensDirection.back;
  CameraController? _controller;
  bool _torchOn = false;

  @override
  Widget build(BuildContext context) => VisibilityDetector(
    key: const ValueKey<String>('VisibilityDetector'),
    onVisibilityChanged: (final VisibilityInfo info) {
      final bool visible = info.visibleFraction > 0;
      if (!mounted || visible == _visible) {
        return;
      }
      setState(() {
        _visible = visible;
        if (!visible) {
          _controller = null;
          _torchOn = false;
        }
      });
    },
    child: Stack(
      children: <Widget>[
        if (_visible)
          ReaderWidget(
            codeFormat: _formats,
            lensDirection: _lensDirection,
            onScan: (final Code code) async {
              final String? text = code.text;
              if (text != null && text.isNotEmpty) {
                await widget.onScan(text);
              }
            },
            onControllerCreated:
                (final CameraController? controller, final Exception? _) {
                  if (mounted) {
                    setState(() {
                      _controller = controller;
                      _torchOn = false;
                    });
                  }
                },
            showScannerOverlay: false,
            showFlashlight: false,
            showToggleCamera: false,
            showGallery: false,
            allowPinchZoom: false,
            cropPercent: 0,
            scanDelay: const Duration(milliseconds: 250),
            loading: SCANNER_EMPTY_WIDGET,
          ),
        Center(
          child: SmoothBarcodeScannerVisor(
            icon: widget.barcodeScannerIcon,
            contentPadding: widget.contentPadding,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(
              SmoothBarcodeScannerVisor.CORNER_PADDING,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.hasMoreThanOneCamera)
                  VisorButton(
                    tooltip:
                        widget.toggleCameraModeTooltip ??
                        'Switch between back and front camera',
                    onTap: () {
                      widget.hapticFeedback();
                      setState(() {
                        _lensDirection =
                            _lensDirection == CameraLensDirection.back
                            ? CameraLensDirection.front
                            : CameraLensDirection.back;
                        _controller = null;
                        _torchOn = false;
                      });
                    },
                    child: Icon(
                      _lensDirection == CameraLensDirection.front
                          ? Icons.camera_front
                          : Icons.camera_rear,
                    ),
                  )
                else
                  SCANNER_EMPTY_WIDGET,
                if (_controller != null &&
                    _lensDirection == CameraLensDirection.back)
                  VisorButton(
                    tooltip:
                        widget.toggleFlashModeTooltip ??
                        'Turn ON or OFF the flash of the camera',
                    onTap: _toggleTorch,
                    child: _torchOn ? widget.torchOnIcon : widget.torchOffIcon,
                  )
                else
                  SCANNER_EMPTY_WIDGET,
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _toggleTorch() async {
    widget.hapticFeedback();
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    try {
      await controller.setFlashMode(_torchOn ? FlashMode.off : FlashMode.torch);
      if (mounted) {
        setState(() => _torchOn = !_torchOn);
      }
    } catch (_) {
      if (mounted) {
        widget.onCameraFlashError?.call(context);
      }
    }
  }
}
