import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth_app/pages/prices/eraser_model.dart';

/// Painter of the eraser tool: displaying thick lines.
class EraserPainter extends CustomPainter {
  EraserPainter({required this.eraserModel, this.cropRect});

  final EraserModel eraserModel;
  final Rect? cropRect;

  static const Color color = Colors.black;

  final Paint _paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Path _path = Path();

  void _addToPath(final Offset start, final Offset end) {
    _path.moveTo(start.dx, start.dy);
    _path.lineTo(end.dx, end.dy);
  }

  static const double _strokeWidthFactor = .03;

  @override
  void paint(Canvas canvas, Size size) {
    eraserModel.size = size;

    eraserModel.cropRect = cropRect;

    if (cropRect == null) {
      _paint.strokeWidth = _strokeWidthFactor * sqrt(size.width * size.height);
    } else {
      _paint.strokeWidth =
          _strokeWidthFactor *
          sqrt(size.width * size.height / cropRect!.width / cropRect!.height);
    }

    _path.reset();
    for (int i = 0; i < eraserModel.length; i++) {
      _addToPath(eraserModel.getStart(i), eraserModel.getEnd(i));
    }
    final Offset? currentStart = eraserModel.getCurrentStart();
    final Offset? currentEnd = eraserModel.getCurrentEnd();
    if (currentStart != null && currentEnd != null) {
      _addToPath(currentStart, currentEnd);
    }

    eraserModel.cropRect = null;

    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
