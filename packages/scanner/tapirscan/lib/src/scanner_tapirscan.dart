import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:tapirscan/tapirscan.dart' as ts;
import 'package:visibility_detector/visibility_detector.dart';

/// Formats and effort of the Tapirscan scanner: the formats of the other
/// scanners, at Tapirscan's default (medium) effort.
const ts.ScannerOptions tapirscanOptions = ts.ScannerOptions(
  mode: ts.Mode.medium,
  formats: <ts.Format>{
    ts.Format.ean13,
    ts.Format.ean8,
    ts.Format.upcA,
    ts.Format.upcE,
    ts.Format.code39,
    ts.Format.code93,
    ts.Format.code128,
    ts.Format.itf,
    ts.Format.qrCode,
    ts.Format.dataMatrix,
  },
);

/// Scanner implementation using Tapirscan (tested on 64-bit Android)
class ScannerTapirscan extends Scanner {
  const ScannerTapirscan();

  @override
  String getType() => 'Tapirscan';

  @override
  CustomScannerController getController() => _TapirscanController();

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
    return _SmoothBarcodeScannerTapirscan(
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
class _TapirscanController implements CustomScannerController {
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
          return _TapirscanCameraView(
            lensDirection: _lensDirection,
            onScan: onScan,
            onCameraCreated: _onCameraCreated,
          );
        },
      );
}

/// Camera preview whose YUV frames are decoded by Tapirscan, one at a time.
class _TapirscanCameraView extends StatefulWidget {
  const _TapirscanCameraView({
    required this.lensDirection,
    required this.onScan,
    required this.onCameraCreated,
  });

  final CameraLensDirection lensDirection;
  final void Function(String barcode) onScan;
  final void Function(CameraController? camera) onCameraCreated;

  @override
  State<_TapirscanCameraView> createState() => _TapirscanCameraViewState();
}

class _TapirscanCameraViewState extends State<_TapirscanCameraView>
    with WidgetsBindingObserver {
  /// Pause between two decoded frames.
  static const Duration _scanDelay = Duration(milliseconds: 120);

  /// Camera opens and releases of every view, one at a time, so that switching
  /// cameras never opens the new one before the old one is released.
  static Future<void> _transition = Future<void>.value();

  /// Queues [task] after the previous transitions. A failing task is logged,
  /// so that it cannot stop the transitions queued after it.
  static void _enqueue(Future<void> Function() task) {
    _transition = _transition.then((_) => task()).catchError((Object error) {
      debugPrint('Tapirscan camera transition failed: $error');
    });
  }

  CameraController? _camera;
  ts.Scanner? _scanner;

  /// Increments on every camera (re)start; frames of older cameras are dropped.
  int _generation = 0;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _active = _isActive(WidgetsBinding.instance.lifecycleState);
    _reconcile();
  }

  /// Permission dialogs and split-screen focus changes only make the app
  /// inactive; the camera is released when it is hidden or paused.
  static bool _isActive(AppLifecycleState? state) =>
      state == null ||
      state == AppLifecycleState.resumed ||
      state == AppLifecycleState.inactive;

  @override
  void didUpdateWidget(_TapirscanCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lensDirection != widget.lensDirection) {
      _reconcile();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool active = _isActive(state);
    if (active != _active) {
      _active = active;
      _reconcile();
    }
  }

  /// Releases the camera and, if still wanted, opens it again.
  void _reconcile() {
    final int generation = ++_generation;
    _enqueue(() async {
      await _release(notify: true);
      if (!mounted || generation != _generation || !_active) {
        return;
      }
      try {
        final List<CameraDescription> cameras = await availableCameras();
        if (cameras.isEmpty) {
          throw StateError('No camera available');
        }
        final CameraDescription description = cameras.firstWhere(
          (final CameraDescription camera) =>
              camera.lensDirection == widget.lensDirection,
          orElse: () => cameras.first,
        );
        // Throws UnsupportedError where Tapirscan has no library (32-bit).
        final ts.Scanner scanner = ts.Scanner(tapirscanOptions);
        _scanner = scanner;
        final CameraController camera = CameraController(
          description,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        _camera = camera;
        await camera.initialize();
        if (!mounted || generation != _generation) {
          await _release(notify: false);
          return;
        }
        await camera.startImageStream(
          (final CameraImage image) => _onFrame(image, scanner, generation),
        );
        if (mounted && generation == _generation) {
          widget.onCameraCreated(camera);
          setState(() {});
        }
      } catch (error) {
        debugPrint('Tapirscan camera failed: $error');
        await _release(notify: true);
      }
    });
  }

  bool _busy = false;
  DateTime _nextFrame = DateTime.now();

  Future<void> _onFrame(
    CameraImage image,
    ts.Scanner scanner,
    int generation,
  ) async {
    if (_busy ||
        generation != _generation ||
        DateTime.now().isBefore(_nextFrame)) {
      return;
    }
    _busy = true;
    try {
      // The Y plane of a YUV420 frame is a gray image with its row stride.
      final Plane luma = image.planes.first;
      final ts.ScanResult result = await scanner.scan(
        ts.PixelImage(
          luma.bytes,
          width: image.width,
          height: image.height,
          stride: luma.bytesPerRow,
        ),
      );
      final String? code = result.best?.text;
      if (code != null &&
          code.isNotEmpty &&
          mounted &&
          generation == _generation) {
        widget.onScan(code);
      }
    } catch (error) {
      // A frame that fails is skipped; the next one is scanned as usual.
      debugPrint('Tapirscan frame failed: $error');
    } finally {
      _busy = false;
      _nextFrame = DateTime.now().add(_scanDelay);
    }
  }

  Future<void> _release({required bool notify}) async {
    final CameraController? camera = _camera;
    final ts.Scanner? scanner = _scanner;
    _camera = null;
    _scanner = null;
    if (camera != null && notify && mounted) {
      widget.onCameraCreated(null);
      setState(() {});
    }
    try {
      await camera?.dispose();
    } catch (error) {
      debugPrint('Camera cleanup failed: $error');
    }
    try {
      scanner?.dispose();
    } catch (error) {
      debugPrint('Tapirscan cleanup failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return SCANNER_EMPTY_WIDGET;
    }
    // Fill the scanner box and crop, as flutter_zxing's ReaderWidget does:
    // the preview gets a width only and keeps its own aspect ratio.
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: constraints.maxWidth,
              child: CameraPreview(camera),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ++_generation;
    _enqueue(() => _release(notify: false));
    super.dispose();
  }
}

/// Barcode scanner based on Tapirscan.
class _SmoothBarcodeScannerTapirscan extends StatefulWidget {
  const _SmoothBarcodeScannerTapirscan({
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
  State<StatefulWidget> createState() => _SmoothBarcodeScannerTapirscanState();
}

class _SmoothBarcodeScannerTapirscanState
    extends State<_SmoothBarcodeScannerTapirscan> {
  final _TapirscanController _controller = _TapirscanController();

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
