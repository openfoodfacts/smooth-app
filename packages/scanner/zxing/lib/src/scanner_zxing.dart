import 'dart:async';

import 'package:camera/camera.dart'
    show CameraDescription, FlashMode, availableCameras;
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
  CustomScannerController getController() => _ZXingController();

  @override
  Future<bool> hasCamera({required bool front}) async {
    final CameraLensDirection direction = front
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    return (await availableCameras()).any(
      (final CameraDescription camera) => camera.lensDirection == direction,
    );
  }

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

/// Not a [Listenable] itself: the app hands it to a plain `Provider`, which
/// rejects listenables. Changes go through [hasTorchState] instead.
class _ZXingController implements CustomScannerController {
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

  final _Changes _changes = _Changes();
  bool _started = false;
  bool _disposed = false;
  CameraLensDirection _lensDirection = CameraLensDirection.back;
  CameraController? _camera;
  bool _torchOn = false;

  CameraLensDirection get lensDirection => _lensDirection;

  @override
  bool get isStarted => _started;

  @override
  Listenable get hasTorchState => _changes;

  @override
  bool get hasTorch =>
      _camera != null && _lensDirection == CameraLensDirection.back;

  @override
  bool get isTorchOn => _torchOn;

  @override
  Future<void> start() async {
    if (!_started) {
      _started = true;
      _notify();
    }
  }

  @override
  Future<void> stop() async {
    if (_started) {
      _started = false;
      _resetCamera();
    }
  }

  @override
  void onPause() {}

  @override
  void toggleCamera() {
    _lensDirection = _lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    _resetCamera();
  }

  @override
  void turnTorchOn() => unawaited(_trySetTorch(true));

  @override
  void turnTorchOff() => unawaited(_trySetTorch(false));

  Future<void> _trySetTorch(bool on) async {
    try {
      await setTorch(on);
    } catch (_) {}
  }

  Future<void> setTorch(bool on) async {
    final CameraController? camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return;
    }
    await camera.setFlashMode(on ? FlashMode.torch : FlashMode.off);
    if (identical(camera, _camera)) {
      _torchOn = on;
      _notify();
    }
  }

  void _onCameraCreated(CameraController? camera) {
    _camera = camera;
    _torchOn = false;
    _notify();
  }

  void _resetCamera() {
    _camera = null;
    _torchOn = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      _changes.notify();
    }
  }

  void dispose() {
    _disposed = true;
    _changes.dispose();
  }

  @override
  Widget buildCameraView({required void Function(String barcode) onScan}) =>
      ListenableBuilder(
        listenable: _changes,
        builder: (BuildContext context, _) {
          if (!_started) {
            return SCANNER_EMPTY_WIDGET;
          }
          return ReaderWidget(
            codeFormat: _formats,
            lensDirection: _lensDirection,
            onScan: (final Code code) {
              final String? text = code.text;
              if (text != null && text.isNotEmpty) {
                onScan(text);
              }
            },
            onControllerCreated:
                (final CameraController? camera, final Exception? _) =>
                    _onCameraCreated(camera),
            showScannerOverlay: false,
            showFlashlight: false,
            showToggleCamera: false,
            showGallery: false,
            allowPinchZoom: false,
            cropPercent: 0,
            scanDelay: const Duration(milliseconds: 250),
            loading: SCANNER_EMPTY_WIDGET,
          );
        },
      );
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
  final _ZXingController _controller = _ZXingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
    key: const ValueKey<String>('VisibilityDetector'),
    onVisibilityChanged: (final VisibilityInfo info) {
      if (!mounted) {
        return;
      }
      if (info.visibleFraction > 0) {
        _controller.start();
      } else {
        _controller.stop();
      }
    },
    child: Stack(
      children: <Widget>[
        _controller.buildCameraView(
          onScan: (final String barcode) => unawaited(widget.onScan(barcode)),
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
            child: ListenableBuilder(
              listenable: _controller.hasTorchState,
              builder: (BuildContext context, _) => Row(
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
                        _controller.toggleCamera();
                      },
                      child: Icon(
                        _controller.lensDirection == CameraLensDirection.front
                            ? Icons.camera_front
                            : Icons.camera_rear,
                      ),
                    )
                  else
                    SCANNER_EMPTY_WIDGET,
                  if (_controller.hasTorch)
                    VisorButton(
                      tooltip:
                          widget.toggleFlashModeTooltip ??
                          'Turn ON or OFF the flash of the camera',
                      onTap: _toggleTorch,
                      child: _controller.isTorchOn
                          ? widget.torchOnIcon
                          : widget.torchOffIcon,
                    )
                  else
                    SCANNER_EMPTY_WIDGET,
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _toggleTorch() async {
    widget.hapticFeedback();
    try {
      await _controller.setTorch(!_controller.isTorchOn);
    } catch (_) {
      if (mounted) {
        widget.onCameraFlashError?.call(context);
      }
    }
  }
}

class _Changes extends ChangeNotifier {
  void notify() => notifyListeners();
}
