import 'package:flutter/material.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothHtmlDecimal extends StatelessWidget {
  const SmoothHtmlDecimal({
    required this.index,
    super.key,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return CustomPaint(
      painter: _HtmlDecimalPainter(
        color:
            context.lightTheme() ? extension.greyLight : extension.greyNormal,
        index: index,
        textDirection: Directionality.of(context),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const SizedBox.square(dimension: 10.0),
    );
  }
}

class _HtmlDecimalPainter extends CustomPainter {
  _HtmlDecimalPainter({
    required this.index,
    required this.color,
    required this.textDirection,
    required this.textStyle,
  });

  final int index;
  final Color color;
  final TextDirection textDirection;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final double halfSize = size.width / 2;

    canvas.translate(-10.0, 0.0);

    canvas.drawCircle(
      Offset(halfSize, halfSize),
      size.width,
      Paint()..color = color,
    );

    final TextPainter textPainter = TextPainter(textDirection: textDirection);
    textPainter.text = TextSpan(
      text: index.toString(),
      style: textStyle,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_HtmlDecimalPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_HtmlDecimalPainter oldDelegate) => false;
}
