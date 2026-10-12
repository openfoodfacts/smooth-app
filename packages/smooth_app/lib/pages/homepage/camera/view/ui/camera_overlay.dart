import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/homepage/camera/view/ui/camera_view.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class HomePageCameraOverlay extends StatefulWidget {
  const HomePageCameraOverlay({required this.barcodes, super.key});

  final Stream<DetectedBarcode> barcodes;

  @override
  State<HomePageCameraOverlay> createState() => _HomePageCameraOverlayState();
}

class _HomePageCameraOverlayState extends State<HomePageCameraOverlay> {
  DetectedBarcode? _currentBarcode;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.barcodes.listen(_onBarcodeDetected);
  }

  void _onBarcodeDetected(DetectedBarcode code) {
    _timer?.cancel();
    setState(() {
      _currentBarcode = code;
    });

    _timer = Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _currentBarcode = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentBarcode == null || _currentBarcode!.hasSize != true) {
      return EMPTY_WIDGET;
    }

    return CustomPaint(
      foregroundPainter: _CameraBarcodePainter(
        barcode: _currentBarcode!,
        color: context.extension<SmoothColorsThemeExtension>().primaryMedium,
      ),
      size: MediaQuery.sizeOf(context),
    );
  }
}

class _CameraBarcodePainter extends CustomPainter {
  _CameraBarcodePainter({required this.barcode, required Color color})
    : _paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = true;

  final DetectedBarcode barcode;
  final Paint _paint;
  final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final double widthFactor = size.width / barcode.width!;
    final double heightFactor = size.height / barcode.height!;

    _path.reset();

    for (int i = 0; i < barcode.corners.length; i++) {
      if (i == 0) {
        _path.moveTo(
          barcode.corners[i].dx * widthFactor,
          barcode.corners[i].dy * heightFactor,
        );
      } else {
        _path.lineTo(
          barcode.corners[i].dx * widthFactor,
          barcode.corners[i].dy * heightFactor,
        );
      }
    }

    _path.close();

    canvas.drawPath(_path, _paint);
    canvas.drawShadow(_path, Colors.white.withValues(alpha: 0.5), 2.0, false);
  }

  @override
  bool shouldRepaint(covariant _CameraBarcodePainter oldDelegate) =>
      barcode != oldDelegate.barcode;
}
