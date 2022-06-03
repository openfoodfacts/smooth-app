import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScannerVisorWidget extends StatelessWidget {
  const ScannerVisorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: getSize(context),
      child: CustomPaint(
        painter: ScanVisorPainter(),
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

  /// Returns the Size of the visor
  static Size getSize(BuildContext context) => Size(
        MediaQuery.of(context).size.width * 0.8,
        150.0,
      );
}

class ScanVisorPainter extends CustomPainter {
  ScanVisorPainter();

  static const double _fullCornerSize = 31.0;
  static const double _halfCornerSize = _fullCornerSize / 2;
  static const Radius _borderRadius = Radius.circular(_halfCornerSize);

  final Paint _paint = Paint()
    ..strokeWidth = 3.0
    ..color = Colors.white
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    canvas.drawPath(getPath(rect, false), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  /// Returns a path to draw the visor
  /// [includeLineBetweenCorners] will draw lines between each corner, instead
  /// of moving the cursor
  static Path getPath(Rect rect, bool includeLineBetweenCorners) {
    final Path path = Path()
      // Top left
      ..moveTo(rect.left, rect.top + _fullCornerSize)
      ..lineTo(rect.left, rect.top + _halfCornerSize)
      ..arcToPoint(
        Offset(rect.left + _halfCornerSize, rect.top),
        radius: _borderRadius,
      )
      ..lineTo(rect.left + _fullCornerSize, rect.top);

    // Top right
    if (includeLineBetweenCorners) {
      path.lineTo(rect.right - _fullCornerSize, rect.top);
    } else {
      path.moveTo(rect.right - _fullCornerSize, rect.top);
    }

    path
      ..lineTo(rect.right - _halfCornerSize, rect.top)
      ..arcToPoint(
        Offset(rect.right, _halfCornerSize),
        radius: _borderRadius,
      )
      ..lineTo(rect.right, rect.top + _fullCornerSize);

    // Bottom right
    if (includeLineBetweenCorners) {
      path.lineTo(rect.right, rect.bottom - _fullCornerSize);
    } else {
      path.moveTo(rect.right, rect.bottom - _fullCornerSize);
    }

    path
      ..lineTo(rect.right, rect.bottom - _halfCornerSize)
      ..arcToPoint(
        Offset(rect.right - _halfCornerSize, rect.bottom),
        radius: _borderRadius,
      )
      ..lineTo(rect.right - _fullCornerSize, rect.bottom);

    // Bottom left
    if (includeLineBetweenCorners) {
      path.lineTo(rect.left + _fullCornerSize, rect.bottom);
    } else {
      path.moveTo(rect.left + _fullCornerSize, rect.bottom);
    }

    path
      ..lineTo(rect.left + _halfCornerSize, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.bottom - _halfCornerSize),
        radius: _borderRadius,
      )
      ..lineTo(rect.left, rect.bottom - _fullCornerSize);

    if (includeLineBetweenCorners) {
      path.lineTo(rect.left, rect.top + _halfCornerSize);
    }

    return path;
  }
}
