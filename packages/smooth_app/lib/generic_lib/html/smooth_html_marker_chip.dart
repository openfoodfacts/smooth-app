import 'package:flutter/material.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothHtmlChip extends StatelessWidget {
  const SmoothHtmlChip({super.key});

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    /// We can't use top Padding, so we draw on a canvas
    return CustomPaint(
      painter: _HtmlChipPainter(
        color:
            context.lightTheme() ? extension.greyLight : extension.greyNormal,
        textDirection: Directionality.of(context),
      ),
      child: const SizedBox.square(dimension: 10.0),
    );
  }
}

class _HtmlChipPainter extends CustomPainter {
  _HtmlChipPainter({
    required this.color,
    required this.textDirection,
  });

  final Color color;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final double dimension = size.width;
    final double halfSize = size.width / 2;

    canvas.translate(-10.0, 0.0);

    canvas.drawCircle(
      Offset(halfSize, halfSize + 0.5),
      size.width,
      Paint()..color = color,
    );

    final IconData icon = const icons.Arrow.right().icon;
    final TextPainter textPainter = TextPainter(textDirection: textDirection);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(fontSize: dimension, fontFamily: icon.fontFamily),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - dimension) / 2,
        (size.height - dimension) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_HtmlChipPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_HtmlChipPainter oldDelegate) => false;
}
