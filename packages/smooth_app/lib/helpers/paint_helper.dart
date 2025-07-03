import 'package:flutter/rendering.dart';

class DashedLinePainter extends CustomPainter {
  DashedLinePainter({
    required Color color,
    this.dashGap = 3.0,
    this.dashSpace = 3.0,
  }) : _paint = Paint()
         ..color = color
         ..strokeWidth = 1.0;

  final double dashGap;
  final double dashSpace;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashGap, 0), _paint);

      startX += dashGap + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) =>
      dashGap != oldDelegate.dashGap || dashSpace != oldDelegate.dashSpace;
}
