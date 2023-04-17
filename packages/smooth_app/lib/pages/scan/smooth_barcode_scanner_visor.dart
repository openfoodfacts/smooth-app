import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';

class SmoothBarcodeScannerVisor extends StatelessWidget {
  const SmoothBarcodeScannerVisor();

  static const double cornerHorizontalPadding = 24;
  static const double cornerVerticalPadding = 8;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: CustomPaint(
          painter: _ScanVisorPainter(Theme.of(context).scaffoldBackgroundColor),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/visor_icon.svg',
              width: 35.0,
              height: 32.0,
              package: AppHelper.APP_PACKAGE,
            ),
          ),
        ),
      );
}

class _ScanVisorPainter extends CustomPainter {
  _ScanVisorPainter(this.backgroundColor);

  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final Rect bigRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    final Rect rect = Rect.fromLTRB(
      SmoothBarcodeScannerVisor.cornerHorizontalPadding,
      SmoothBarcodeScannerVisor.cornerVerticalPadding,
      size.width - SmoothBarcodeScannerVisor.cornerHorizontalPadding,
      size.height - SmoothBarcodeScannerVisor.cornerVerticalPadding,
    );

    final Path path = Path()..fillType = PathFillType.evenOdd;
    path.addRect(bigRect);
    path.addRRect(RRect.fromRectAndRadius(rect, ROUNDED_RADIUS));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
