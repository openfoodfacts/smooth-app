import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmoothBarcodeScannerVisor extends StatelessWidget {
  const SmoothBarcodeScannerVisor(this.height);

  final double height;

  static const double cornerPadding = 26;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) =>
          SizedBox.expand(
        child: CustomPaint(
          painter: _ScanVisorPainter(height),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/visor_icon.svg',
              width: 35.0,
              height: 32.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanVisorPainter extends CustomPainter {
  _ScanVisorPainter(this.height);

  final double height;

  static const double strokeWidth = 3.0;
  static const double _fullCornerSize = 31.0;
  static const double _halfCornerSize = _fullCornerSize / 2;
  static const Radius _borderRadius = Radius.circular(_halfCornerSize);

  final Paint _paint = Paint()
    ..strokeWidth = strokeWidth
    ..color = Colors.white
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: height,
    );
    canvas.drawPath(getPath(rect, false), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  /// Returns a path to draw the visor
  /// [includeLineBetweenCorners] will draw lines between each corner, instead
  /// of moving the cursor
  static Path getPath(Rect rect, bool includeLineBetweenCorners) {
    final double bottomPosition;
    if (includeLineBetweenCorners) {
      bottomPosition = rect.bottom - strokeWidth;
    } else {
      bottomPosition = rect.bottom;
    }

    final Path path = Path()..moveTo(rect.left, rect.top + _fullCornerSize);

    // Top left
    path
      ..lineTo(rect.left, rect.top + _halfCornerSize)
      ..arcToPoint(
        Offset(rect.left + _halfCornerSize, rect.top),
        radius: _borderRadius,
      )
      ..lineTo(rect.left + _fullCornerSize, rect.top);

    void moveToOrLineTo(final double x, final double y) {
      if (includeLineBetweenCorners) {
        path.lineTo(x, y);
      } else {
        path.moveTo(x, y);
      }
    }

    // Top right
    moveToOrLineTo(rect.right - _fullCornerSize, rect.top);

    path
      ..lineTo(rect.right - _halfCornerSize, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + _halfCornerSize),
        radius: _borderRadius,
      )
      ..lineTo(rect.right, rect.top + _fullCornerSize);

    // Bottom right
    moveToOrLineTo(rect.right, bottomPosition - _fullCornerSize);

    path
      ..lineTo(rect.right, bottomPosition - _halfCornerSize)
      ..arcToPoint(
        Offset(rect.right - _halfCornerSize, bottomPosition),
        radius: _borderRadius,
      )
      ..lineTo(rect.right - _fullCornerSize, bottomPosition);

    // Bottom left
    moveToOrLineTo(rect.left + _fullCornerSize, bottomPosition);

    path
      ..lineTo(rect.left + _halfCornerSize, bottomPosition)
      ..arcToPoint(
        Offset(rect.left, bottomPosition - _halfCornerSize),
        radius: _borderRadius,
      )
      ..lineTo(rect.left, bottomPosition - _fullCornerSize);

    moveToOrLineTo(rect.left, rect.top + _halfCornerSize);

    return path;
  }
}
