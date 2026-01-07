import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

enum Side { top, right, bottom, left }

class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required Color color,
    required this.sides,
    this.dashGap = 3.0,
    this.dashSpace = 3.0,
    this.borderRadius = BorderRadius.zero,
  }) : _paint = Paint()
         ..color = color
         ..strokeWidth = 1.0
         ..style = PaintingStyle.stroke;

  final Set<Side> sides;
  final double dashGap;
  final double dashSpace;
  final BorderRadius borderRadius;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final Radius topLeft = borderRadius.topLeft.clamp(
      minimum: Radius.zero,
      maximum: Radius.circular(size.shortestSide / 2),
    );
    final Radius topRight = borderRadius.topRight.clamp(
      minimum: Radius.zero,
      maximum: Radius.circular(size.shortestSide / 2),
    );
    final Radius bottomLeft = borderRadius.bottomLeft.clamp(
      minimum: Radius.zero,
      maximum: Radius.circular(size.shortestSide / 2),
    );
    final Radius bottomRight = borderRadius.bottomRight.clamp(
      minimum: Radius.zero,
      maximum: Radius.circular(size.shortestSide / 2),
    );

    if (sides.contains(Side.top)) {
      drawDashedLine(
        canvas,
        Offset(topLeft.x, 0),
        Offset(size.width - topRight.x, 0),
        true,
      );
      if (topLeft.x > 0) {
        _drawDashedArc(
          canvas,
          Rect.fromLTWH(0, 0, topLeft.x * 2, topLeft.y * 2),
          math.pi,
          math.pi / 2,
        );
      }
      if (topRight.x > 0) {
        _drawDashedArc(
          canvas,
          Rect.fromLTWH(
            size.width - topRight.x * 2,
            0,
            topRight.x * 2,
            topRight.y * 2,
          ),
          -math.pi / 2,
          math.pi / 2,
        );
      }
    }

    if (sides.contains(Side.right)) {
      drawDashedLine(
        canvas,
        Offset(size.width, topRight.y),
        Offset(size.width, size.height - bottomRight.y),
        false,
      );
    }

    if (sides.contains(Side.bottom)) {
      drawDashedLine(
        canvas,
        Offset(size.width - bottomRight.x, size.height),
        Offset(bottomLeft.x, size.height),
        true,
      );
      if (bottomRight.x > 0) {
        _drawDashedArc(
          canvas,
          Rect.fromLTWH(
            size.width - bottomRight.x * 2,
            size.height - bottomRight.y * 2,
            bottomRight.x * 2,
            bottomRight.y * 2,
          ),
          0,
          math.pi / 2,
        );
      }
      if (bottomLeft.x > 0) {
        _drawDashedArc(
          canvas,
          Rect.fromLTWH(
            0,
            size.height - bottomLeft.y * 2,
            bottomLeft.x * 2,
            bottomLeft.y * 2,
          ),
          math.pi / 2,
          math.pi / 2,
        );
      }
    }

    if (sides.contains(Side.left)) {
      drawDashedLine(
        canvas,
        Offset(0, size.height - bottomLeft.y),
        Offset(0, topLeft.y),
        false,
      );
    }
  }

  void _drawDashedArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double sweepAngle,
  ) {
    final Path path = Path()..addArc(rect, startAngle, sweepAngle);
    final PathMetrics pathMetrics = path.computeMetrics();
    for (final PathMetric metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final Path extractPath = metric.extractPath(
          distance,
          (distance + dashGap).clamp(0, metric.length),
        );
        canvas.drawPath(extractPath, _paint);
        distance += dashGap + dashSpace;
      }
    }
  }

  void drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    bool horizontal,
  ) {
    final double length = (end - start).distance;
    final Offset direction = (end - start) / length;
    double drawn = 0.0;
    while (drawn < length) {
      final Offset dashStart = start + direction * drawn;
      final Offset dashEnd =
          start + direction * (drawn + dashGap).clamp(0, length);
      canvas.drawLine(dashStart, dashEnd, _paint);
      drawn += dashGap + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      dashGap != oldDelegate.dashGap ||
      dashSpace != oldDelegate.dashSpace ||
      borderRadius != oldDelegate.borderRadius ||
      sides != oldDelegate.sides;
}
