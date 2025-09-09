import 'package:flutter/material.dart';

class AppBarBackground extends StatelessWidget {
  const AppBarBackground({required this.height, required this.child, super.key})
    : assert(height > 0.0);

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AppBarBackgroundPainter(),
      size: Size(MediaQuery.sizeOf(context).width, height),
      child: child,
    );
  }
}

class AppBarBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    final Offset bottomLeftCenter = Offset(20.0, size.height / 3.0 * 2.0);
    const double bottomLeftRadius = 240.0 / 2.0;
    canvas.drawCircle(bottomLeftCenter, bottomLeftRadius, circlePaint);

    final Offset topRightCenter = Offset(size.width - 20.0, size.height / 3.0);
    const double topRightRadius = 220.0 / 2.0;
    canvas.drawCircle(topRightCenter, topRightRadius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
