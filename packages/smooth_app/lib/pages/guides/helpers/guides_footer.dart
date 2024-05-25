import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class GuidesFooter extends StatelessWidget {
  const GuidesFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return CustomPaint(
      painter: _FooterPainter(
        color: colors.primaryNormal,
        wazeSize: _FooterPainter.WAVE_SIZE,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: _FooterPainter.WAVE_SIZE + MEDIUM_SPACE,
            start: VERY_LARGE_SPACE,
            end: VERY_LARGE_SPACE,
            bottom: 10.0 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: colors.primaryBlack,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: VERY_LARGE_SPACE / 2,
                vertical: VERY_LARGE_SPACE,
              ),
            ),
            // TODO(g123k): Implement sharing functionality
            child: const Text(
              'Partager',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
              ),
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

class _FooterPainter extends CustomPainter {
  _FooterPainter({
    this.wazeSize = WAVE_SIZE,
    required Color color,
  })  : assert(color.opacity > 0.0),
        _localPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  static const double WAVE_SIZE = 24.0;
  final double wazeSize;
  final Paint _localPaint;

  @override
  void paint(Canvas canvas, Size size) {
    Offset offset = Offset(wazeSize / 2, wazeSize / 2);

    /// Draw top waves
    while (true) {
      canvas.drawArc(
        Rect.fromCenter(
          center: offset,
          height: wazeSize,
          width: wazeSize,
        ),
        math.pi,
        math.pi,
        false,
        _localPaint,
      );

      offset = offset.translate(wazeSize, 0);
      if (offset.dx > (size.width + wazeSize)) {
        break;
      }
    }

    /// Draw background color
    canvas.drawRect(
        Rect.fromLTWH(
          0,
          // 0.5 to eliminate some glitches
          (wazeSize / 2) - 0.5,
          size.width,
          size.height,
        ),
        _localPaint);
  }

  @override
  bool shouldRepaint(_FooterPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_FooterPainter oldDelegate) => false;
}
