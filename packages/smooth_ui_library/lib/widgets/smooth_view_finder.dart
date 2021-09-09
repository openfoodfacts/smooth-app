import 'package:flutter/material.dart';

class SmoothViewFinder extends StatefulWidget {
  const SmoothViewFinder({
    required this.boxSize,
    required this.lineLength,
  });

  final Size boxSize;
  final double lineLength;

  @override
  State<StatefulWidget> createState() => SmoothViewFinderState();
}

class SmoothViewFinderState extends State<SmoothViewFinder>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    lowerBound: 0.3,
    upperBound: 0.8,
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Center(
          child: CustomPaint(
            size: widget.boxSize,
            painter: _Painter(
              lineLength: widget.lineLength,
              lineOpacity: _animationController.value,
            ),
          ),
        );
      },
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({
    this.cornerStrokeWidth = 3.0,
    this.cornerSize = 18.0,
    this.lineWidth = 1.0,
    required this.lineLength,
    required this.lineOpacity,
  });

  final double cornerStrokeWidth;
  final double cornerSize;
  final double lineWidth;
  final double lineLength;
  final double lineOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    // Draw corners
    canvas.drawPath(
      Path()
        // Top left
        ..moveTo(rect.left, rect.top + cornerSize)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + cornerSize, rect.top)
        // Top right
        ..moveTo(rect.right - cornerSize, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.top + cornerSize)
        // Bottom left
        ..moveTo(rect.left, rect.bottom - cornerSize)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left + cornerSize, rect.bottom)
        // Bottom right
        ..moveTo(rect.right - cornerSize, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right, rect.bottom - cornerSize),
      Paint()
        ..strokeWidth = cornerStrokeWidth
        ..color = Colors.white
        ..style = PaintingStyle.stroke,
    );

    canvas.drawLine(
      rect.center.translate(-lineLength / 2, 0),
      rect.center.translate(lineLength / 2, 0),
      Paint()
        ..strokeWidth = lineWidth
        ..color = Colors.white.withOpacity(lineOpacity)
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
