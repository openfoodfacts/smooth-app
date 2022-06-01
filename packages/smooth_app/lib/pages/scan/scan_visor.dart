import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScannerVisorWidget extends StatelessWidget {
  const ScannerVisorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 150.0,
      child: CustomPaint(
        painter: _Painter(),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/visor_icon.svg',
            width: 35.0,
            height: 32.0,
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter();

  static const double _fullCornerSize = 31.0;
  static const double _halfCornerSize = _fullCornerSize / 2;
  static const Radius _borderRadius = Radius.circular(_halfCornerSize);
  static const double cornerStrokeWidth = 3.0;

  final Paint _paint = Paint()
    ..strokeWidth = cornerStrokeWidth
    ..color = Colors.white
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    // Draw corners
    canvas.drawPath(
        Path()
          // Top left
          ..moveTo(rect.left, rect.top + _fullCornerSize)
          ..lineTo(rect.left, rect.top + _halfCornerSize)
          ..arcToPoint(
            Offset(rect.left + _halfCornerSize, rect.top),
            radius: _borderRadius,
          )
          ..lineTo(rect.left + _fullCornerSize, rect.top)

          // Top right
          ..moveTo(rect.right - _fullCornerSize, rect.top)
          ..lineTo(rect.right - _halfCornerSize, rect.top)
          ..arcToPoint(
            Offset(rect.right, _halfCornerSize),
            radius: _borderRadius,
          )
          ..lineTo(rect.right, rect.top + _fullCornerSize)

          // Bottom right
          ..moveTo(rect.right, rect.bottom - _fullCornerSize)
          ..lineTo(rect.right, rect.bottom - _halfCornerSize)
          ..arcToPoint(
            Offset(rect.right - _halfCornerSize, rect.bottom),
            radius: _borderRadius,
          )
          ..lineTo(rect.right - _fullCornerSize, rect.bottom)

          // Bottom left
          ..moveTo(rect.left + _fullCornerSize, rect.bottom)
          ..lineTo(rect.left + _halfCornerSize, rect.bottom)
          ..arcToPoint(
            Offset(rect.left, rect.bottom - _halfCornerSize),
            radius: _borderRadius,
          )
          ..lineTo(rect.left, rect.bottom - _fullCornerSize),
        _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
