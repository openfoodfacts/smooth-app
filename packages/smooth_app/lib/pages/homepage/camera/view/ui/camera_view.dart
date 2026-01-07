// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_error.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/homepage/camera/view/ui/camera_overlay.dart';
import 'package:smooth_app/pages/homepage/camera/view/ui/scanner_buttons_bar.dart';
import 'package:smooth_app/pages/homepage/camera/view/ui/scanner_message_overlay.dart';
import 'package:smooth_app/pages/homepage/homepage.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel.dart';
import 'package:smooth_app/pages/scan/scan_product_card_loader.dart';
import 'package:torch_light/torch_light.dart';

class HomePageCameraView extends StatefulWidget {
  const HomePageCameraView({
    required this.controller,
    required this.progress,
    required this.onClosed,
    super.key,
  });

  final CustomScannerController controller;
  final double progress;
  final VoidCallback onClosed;

  @override
  State<HomePageCameraView> createState() => _HomePageCameraViewState();
}

class _HomePageCameraViewState extends State<HomePageCameraView> {
  /// A [Stream] for the [HomePageCameraOverlay]
  final StreamController<DetectedBarcode> _barcodeStream =
      StreamController<DetectedBarcode>();

  @override
  Widget build(BuildContext context) {
    final bool isCameraFullyVisible = _isCameraFullyVisible();

    return Provider<CustomScannerController>.value(
      value: widget.controller,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: MobileScanner(
              overlayBuilder: (_, _) =>
                  HomePageCameraOverlay(barcodes: _barcodeStream.stream),
              controller: widget.controller._controller,
              placeholderBuilder: (_, _) =>
                  const SizedBox.expand(child: ColoredBox(color: Colors.black)),
              onDetect: (BarcodeCapture capture) {
                // Only pass if the camera is fully visible and the sheet is not visible and/or scrolled
                if (HomePage.of(context).isCameraFullyVisible) {
                  final String barcode = capture.barcodes.first.rawValue!;
                  context.read<ContinuousScanModel>().onScan(barcode);
                }
              },
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            start: 0.0,
            end: 0.0,
            child: Offstage(
              offstage: !isCameraFullyVisible,
              child: HomePageScannerButtonBars(onClosed: widget.onClosed),
            ),
          ),
          if (isCameraFullyVisible)
            PositionedDirectional(
              // TODO(g123k): Change the hardcoded values
              bottom: 20.0 + 50.0,
              start: 0.0,
              end: 0.0,
              child: SafeArea(bottom: true, child: _MessageOverlay()),
            ),
          Positioned.fill(
            child: _OpaqueOverlay(
              isCameraFullyVisible: isCameraFullyVisible,
              progress: widget.progress,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCameraFullyVisible() => widget.progress < 0.02;
}

class DetectedBarcode {
  DetectedBarcode({
    required this.barcode,
    required this.corners,
    required this.width,
    required this.height,
  });

  final String barcode;
  final List<Offset> corners;
  final double? width;
  final double? height;

  bool get hasSize => width != null && height != null;
}

/// The message overlay is only visible when the [HomePageCameraViewStateManager] emits
/// a [CameraViewNoBarcodeState] or a [CameraViewInvalidBarcodeState].
class _MessageOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ContinuousScanModel>(
      builder: (BuildContext context, ContinuousScanModel model, _) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        if (model.latestConsultedBarcode == null) {
          return HomePageScannerMessageOverlay(
            message: appLocalizations.homepage_scanner_banner_start_scanning,
          );
        }

        return Provider<ScanCardDensity>.value(
          value: ScanCardDensity.NORMAL,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.heightOf(context) * 0.35,
            ),
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: switch (model.getBarcodeState(
                model.latestConsultedBarcode!,
              )) {
                ScannedProductState.FOUND => _buildFoundCard(model),
                ScannedProductState.CACHED => _buildFoundCard(model),
                ScannedProductState.LOADING => _buildLoadingCard(model),
                ScannedProductState.FOUND_BUT_CONSIDERED_AS_NOT_FOUND =>
                  _buildNotFoundCard(model),
                ScannedProductState.NOT_FOUND => _buildNotFoundCard(model),
                ScannedProductState.ERROR_INTERNET => _buildErrorCard(model),
                _ => EMPTY_WIDGET,
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoundCard(ContinuousScanModel model) {
    return ScanProductCardLoader(
      barcode: model.latestConsultedBarcode!,
      onRemoveProduct: (_) => _onRemoveProduct(model),
    );
  }

  Widget _buildLoadingCard(ContinuousScanModel model) {
    return ScanProductCardLoading(
      barcode: model.latestConsultedBarcode!,
      onRemoveProduct: (_) => _onRemoveProduct(model),
    );
  }

  Widget _buildNotFoundCard(ContinuousScanModel model) {
    return ScanProductCardNotFound(
      barcode: model.latestConsultedBarcode!,
      onAddProduct: () => model.refresh(),
      onRemoveProduct: (_) => _onRemoveProduct(model),
    );
  }

  Widget _buildErrorCard(ContinuousScanModel model) {
    return ScanProductCardError(
      barcode: model.latestConsultedBarcode!,
      errorType: ScannedProductState.ERROR_INTERNET,
      onRemoveProduct: (_) => _onRemoveProduct(model),
    );
  }

  void _onRemoveProduct(ContinuousScanModel model) {
    model.lastConsultedBarcode = null;
  }
}

class _OpaqueOverlay extends StatelessWidget {
  const _OpaqueOverlay({
    required this.isCameraFullyVisible,
    required this.progress,
  });

  final bool isCameraFullyVisible;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isCameraFullyVisible,
      child: Opacity(
        opacity: progress,
        child: const ColoredBox(color: Colors.black),
      ),
    );
  }
}

class CustomScannerController {
  CustomScannerController({required MobileScannerController controller})
    : _controller = controller,
      _torchState = _TorchState() {
    _detectTorch();
  }

  final MobileScannerController _controller;
  final _TorchState _torchState;

  bool _isStarted = false;
  bool _isStarting = false;
  bool _isClosing = false;
  bool _isClosed = false;

  Future<void> start() async {
    if (isStarted || _isStarting || isClosing) {
      return;
    }

    _isStarting = true;
    _isClosed = false;
    try {
      await _controller.start();
      _isStarted = true;

      if (isTorchOn) {
        // Slight delay, because it doesn't always work if called immediately
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          turnTorchOn();
        });
      }
      _isStarting = false;
    } catch (_) {}
  }

  void onPause() {
    _isStarted = false;
    _isStarting = false;
    _isClosing = false;
    _isClosed = false;
  }

  bool get isStarted => _isStarted;

  bool get isClosing => _isClosing;

  bool get isClosed => _isClosed;

  Future<void> stop() async {
    if (isClosed || isClosing || _isStarting) {
      return;
    }

    _isClosing = true;
    _isStarting = false;
    _isStarted = false;
    try {
      await _controller.stop();
      _isClosing = false;
      _isClosed = true;
    } catch (_) {}
  }

  ValueNotifier<bool?> get hasTorchState => _torchState;

  bool get isTorchOn => _torchState.value == true;

  void turnTorchOff() {
    if (isTorchOn) {
      _controller.toggleTorch();
      _torchState.value = false;
    }
  }

  void turnTorchOn() {
    if (!isTorchOn) {
      _controller.toggleTorch();
      _torchState.value = true;
    }
  }

  void toggleCamera() {
    _controller.switchCamera();
    if (_controller.facing == CameraFacing.front) {
      _torchState.value = null;
    } else if (_controller.facing == CameraFacing.front) {
      _torchState.value = false;
    }
  }

  Future<void> _detectTorch() async {
    try {
      final bool isTorchAvailable = await TorchLight.isTorchAvailable();
      if (isTorchAvailable) {
        _torchState.value = false;
      } else {
        _torchState.value = null;
      }
    } on Exception catch (_) {}
  }
}

class _TorchState extends ValueNotifier<bool?> {
  _TorchState({bool? value}) : super(value);
}
