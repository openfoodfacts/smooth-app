import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class AppBarBackground extends StatelessWidget {
  const AppBarBackground({
    required this.child,
    required this.scrollOffset,
    required this.minHeight,
    required this.maxHeight,
    required this.bodyHeight,
    required this.footerHeight,
    super.key,
  });

  final Widget child;
  final double scrollOffset;
  final double minHeight;
  final double maxHeight;
  final double bodyHeight;
  final double footerHeight;

  static const Radius RADIUS = Radius.circular(26.0);

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return CustomPaint(
      painter: AppBarBackgroundPainter(
        offset: scrollOffset,
        backgroundColor: lightTheme ? extension.primaryBlack : Colors.black,
        shadowColor:
            AppBarTheme.of(context).shadowColor ??
            Theme.of(context).shadowColor,
        borderRadius: const BorderRadius.vertical(bottom: RADIUS),
        bodyHeight: bodyHeight,
        minHeight: minHeight,
        maxHeight: maxHeight,
        footerHeight: footerHeight,
        footerColor: lightTheme
            ? extension.primaryMedium
            : extension.primaryUltraBlack,
      ),
      child: child,
    );
  }
}

class AppBarBackgroundPainter extends CustomPainter {
  AppBarBackgroundPainter({
    required this.offset,
    required this.minHeight,
    required this.maxHeight,
    required this.bodyHeight,
    required this.footerHeight,
    required this.backgroundColor,
    required this.footerColor,
    required this.shadowColor,
    required this.borderRadius,
  });

  final double offset;
  final double bodyHeight;
  final double minHeight;
  final double maxHeight;
  final double footerHeight;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color footerColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawShadow(canvas, size);

    if (footerHeight > 0.0) {
      _drawFooterBackground(canvas, size);
    }

    canvas.save();
    final Size bodySize = Size(size.width, bodyHeight - offset);
    _drawBackground(canvas, size, bodySize);
    canvas.restore();
  }

  void _drawBackground(Canvas canvas, Size size, Size bodySize) {
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Offset.zero & bodySize,
        bottomLeft: ROUNDED_RADIUS,
        bottomRight: ROUNDED_RADIUS,
      ),
    );

    _drawBackgroundColor(canvas, bodySize);
    _drawShapes(canvas, size);
  }

  void _drawShapes(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    final Offset bottomLeftCenter = Offset(20.0, maxHeight / 3.0 * 2.0);
    const double bottomLeftRadius = 240.0 / 2.0;
    canvas.drawCircle(bottomLeftCenter, bottomLeftRadius, circlePaint);

    final Offset topRightCenter = Offset(size.width - 20.0, maxHeight / 3.0);
    const double topRightRadius = 220.0 / 2.0;
    canvas.drawCircle(topRightCenter, topRightRadius, circlePaint);
  }

  void _drawBackgroundColor(Canvas canvas, Size bodySize) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Offset.zero & bodySize,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      Paint()..color = backgroundColor,
    );
  }

  void _drawShadow(Canvas canvas, Size size) {
    if (offset == 0.0) {
      return;
    }

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Offset.zero & size,
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        ),
      );
    canvas.drawShadow(path, shadowColor, offset.clamp(0.0, 2.0), false);
  }

  void _drawFooterBackground(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0.0, bodyHeight - borderRadius.bottomLeft.y - offset);
    final Paint paint = Paint()..color = footerColor;

    final Size footerSize = Size(
      size.width,
      footerHeight + borderRadius.bottomLeft.y,
    );

    final Path path = Path()
      ..arcToPoint(
        Offset(borderRadius.topLeft.x, borderRadius.topLeft.y),
        radius: borderRadius.topLeft,
        clockwise: false,
      )
      ..lineTo(
        footerSize.width - borderRadius.topRight.x,
        borderRadius.topRight.y,
      )
      ..arcToPoint(
        Offset(footerSize.width, 0.0),
        radius: borderRadius.topRight,
        clockwise: false,
      )
      ..lineTo(footerSize.width, footerSize.height - borderRadius.bottomRight.y)
      ..arcToPoint(
        Offset(
          footerSize.width - borderRadius.bottomRight.x,
          footerSize.height,
        ),
        radius: borderRadius.bottomRight,
        clockwise: true,
      )
      ..lineTo(borderRadius.bottomRight.x, footerSize.height)
      ..arcToPoint(
        Offset(0.0, footerSize.height - borderRadius.bottomLeft.y),
        radius: borderRadius.bottomLeft,
        clockwise: true,
      )
      ..lineTo(0.0, 0.0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AppBarBackgroundPainter oldDelegate) =>
      offset != oldDelegate.offset ||
      minHeight != oldDelegate.minHeight ||
      maxHeight != oldDelegate.maxHeight ||
      bodyHeight != oldDelegate.bodyHeight ||
      footerHeight != oldDelegate.footerHeight ||
      borderRadius != oldDelegate.borderRadius ||
      backgroundColor != oldDelegate.backgroundColor ||
      footerColor != oldDelegate.footerColor ||
      shadowColor != oldDelegate.shadowColor;
}
