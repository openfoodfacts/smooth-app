import 'package:flutter/material.dart';

class AppBarBackground extends StatelessWidget {
  const AppBarBackground({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AppBarBackgroundPainter(),
      size: Size(MediaQuery.of(context).size.width, height),
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

    final Offset bottomLeftCenter = Offset(20.0, size.height / 3 * 2);
    const double bottomLeftRadius = 240.0 / 2;
    canvas.drawCircle(bottomLeftCenter, bottomLeftRadius, circlePaint);

    final Offset topRightCenter = Offset(size.width - 20.0, size.height / 3);
    const double topRightRadius = 220.0 / 2;
    canvas.drawCircle(topRightCenter, topRightRadius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
