import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductForMeScoreGraph extends StatelessWidget {
  const ProductForMeScoreGraph({super.key});

  // Cf [MatchedProductStatusV2]
  static const List<double> _steps = <double>[
    0.10, // 10% for bad (0-10%)
    0.40, // 40% for average (10-50%)
    0.50, // 50% for good (50-100%)
  ];

  @override
  Widget build(BuildContext context) {
    return ConsumerFilter<ProductPageCompatibility>(
      buildWhen:
          (
            ProductPageCompatibility? previousValue,
            ProductPageCompatibility currentValue,
          ) => previousValue?.score != currentValue.score,
      builder: (BuildContext context, ProductPageCompatibility value, _) {
        final SmoothColorsThemeExtension theme = context
            .extension<SmoothColorsThemeExtension>();
        final bool lightTheme = context.lightTheme();

        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final TextDirection textDirection = Directionality.of(context);

        final int? score = int.tryParse(value.score ?? '-');

        final Color scoreColor = value.color ?? theme.greyNormal;
        final String label = score != null
            ? appLocalizations.product_page_for_me_compatibility_score_value(
                score,
              )
            : appLocalizations
                  .product_page_for_me_compatibility_score_uncomputable;

        return Semantics(
          value: label,
          excludeSemantics: true,
          child: SizedBox(
            height: 60.0,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PositionedDirectional(
                  top: 0.0,
                  start: 0.0,
                  end: 0.0,
                  child: CustomPaint(
                    painter: _ScoreBarPainter(
                      colors: score == null
                          ? <Color>[
                              theme.greyDark,
                              theme.greyMedium,
                              theme.greyLight,
                            ]
                          : <Color>[
                              theme.errorGradient,
                              theme.warningGradient,
                              theme.successGradient,
                            ],
                      sectionPercentages: _steps,
                      textDirection: textDirection,
                    ),
                    foregroundPainter: score != null
                        ? _CircleIndicatorPainter(
                            score: score,
                            color: scoreColor,
                            textDirection: textDirection,
                          )
                        : null,
                  ),
                ),
                PositionedDirectional(
                  top: _CircleIndicatorPainter.circleSize + 8.0,
                  start: 0.0,
                  end: 0.0,
                  child: score != null
                      ? CustomPaint(
                          painter: _ScoreIndicatorPainter(
                            score: score,
                            indicatorColor: scoreColor,
                            indicatorIcon:
                                const icons.Indicator.horizontalBar().icon,
                            indicatorSize: 20.0,
                            text: label,
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: lightTheme
                                  ? theme.primaryDark
                                  : theme.primaryLight,
                            ),
                            textBackgroundColor: scoreColor.withValues(
                              alpha: lightTheme ? 0.2 : 0.65,
                            ),
                            textDirection: textDirection,
                          ),
                        )
                      : Center(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal bar with colored sections representing score ranges
class _ScoreBarPainter extends CustomPainter {
  _ScoreBarPainter({
    required this.colors,
    required this.textDirection,
    this.barHeight = 10.0,
    double barRadius = 10.0,
    this.sectionPercentages,
  }) : assert(barHeight > 0, 'Bar height must be positive'),
       assert(
         barHeight <= _CircleIndicatorPainter.circleSize,
         'Bar height cannot be greater than circle size',
       ),
       assert(barRadius >= 0, 'Bar radius cannot be negative'),
       assert(colors.length == 3, 'Must provide 3 colors'),
       assert(
         sectionPercentages == null ||
             sectionPercentages.length == colors.length,
         'If provided, sectionPercentages must have the same length as colors',
       ),
       barRadius = Radius.circular(barRadius);

  // Only supports 3 colors
  final List<Color> colors;
  final List<double>? sectionPercentages;

  final double barHeight;
  final Radius barRadius;

  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth = size.width;
    final bool isRTL = textDirection == TextDirection.rtl;

    // Calculate vertical center of the canvas
    final double barY = (_CircleIndicatorPainter.circleSize - barHeight) / 2;
    final Paint paint = Paint();

    final int numSections = colors.length;

    final List<double> percentages =
        sectionPercentages ??
        List<double>.filled(numSections, 1.0 / numSections);

    double currentX = 0.0;
    for (int i = 0; i < numSections; i++) {
      final int colorIndex = isRTL ? (numSections - 1 - i) : i;
      final Color sectionColor = colors[colorIndex];

      final double sectionWidth = availableWidth * percentages[i];
      double width = sectionWidth;

      if (i == 0) {
        width += barRadius.x;
      } else if (i == numSections - 1) {
        width += barRadius.x;
      } else {
        width += barRadius.x;
      }

      final double adjustedStartX = i == 0 ? currentX : currentX - barRadius.x;

      _drawRoundedRect(
        Rect.fromLTWH(adjustedStartX, barY, width, barHeight),
        canvas,
        paint..color = sectionColor,
      );

      currentX += sectionWidth;
    }
  }

  void _drawRoundedRect(Rect rect, Canvas canvas, Paint paint) =>
      canvas.drawRRect(RRect.fromRectAndRadius(rect, barRadius), paint);

  @override
  bool shouldRepaint(covariant _ScoreBarPainter oldDelegate) =>
      oldDelegate.colors != colors ||
      oldDelegate.sectionPercentages != sectionPercentages ||
      oldDelegate.barHeight != barHeight ||
      oldDelegate.barRadius != barRadius ||
      oldDelegate.textDirection != textDirection;
}

/// Circle indicator above the horizontal bar
/// (only if there's a valid score)
class _CircleIndicatorPainter extends CustomPainter {
  _CircleIndicatorPainter({
    required this.score,
    required this.color,
    required this.textDirection,
  }) : assert(score >= 0 && score <= 100, 'Score must be between 0 and 100');

  final int score;
  final Color color;
  final TextDirection textDirection;

  static const double circleSize = 24.0;
  static const double borderWidth = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth = size.width;

    final double indicatorX = textDirection == TextDirection.rtl
        ? availableWidth - ((score / 100) * availableWidth)
        : (score / 100) * availableWidth;

    // Shadow for border circle
    Paint paint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.fill
      ..strokeWidth = borderWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    canvas.drawCircle(
      Offset(indicatorX, circleSize / 2),
      circleSize / 2,
      paint,
    );

    // Border circle
    paint
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..maskFilter = null;

    canvas.drawCircle(
      Offset(indicatorX, circleSize / 2),
      circleSize / 2,
      paint,
    );

    // Inner circle
    paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(indicatorX, circleSize / 2),
      (circleSize - borderWidth) / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleIndicatorPainter oldDelegate) =>
      oldDelegate.score != score ||
      oldDelegate.color != color ||
      oldDelegate.textDirection != textDirection;
}

/// Score indicator (icon + text)
class _ScoreIndicatorPainter extends CustomPainter {
  _ScoreIndicatorPainter({
    required this.score,
    required this.indicatorColor,
    required this.indicatorIcon,
    required this.text,
    required this.textStyle,
    required this.textBackgroundColor,
    required this.textDirection,
    this.indicatorSize = 16.0,
  }) : assert(score >= 0 && score <= 100, 'Score must be between 0 and 100'),
       assert(text.isNotEmpty, 'Text must not be empty');

  final int score;
  final Color indicatorColor;
  final IconData indicatorIcon;
  final double indicatorSize;
  final String text;
  final TextStyle textStyle;
  final Color textBackgroundColor;
  final TextDirection textDirection;

  static const double textPaddingHorizontal = 10.0;
  static const double textPaddingVertical = 4.0;
  static const double textBorderRadius = 8.0;
  static const double textSpacing = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth = size.width;
    final bool isRTL = textDirection == TextDirection.rtl;

    // Calculate indicator position based on score (0-100)
    // For RTL, flip the position
    final double indicatorX = isRTL
        ? availableWidth - ((score / 100) * availableWidth)
        : (score / 100) * availableWidth;

    // Indicator
    final TextPainter iconPainter = TextPainter(textDirection: textDirection);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(indicatorIcon.codePoint),
      style: TextStyle(
        fontSize: indicatorSize,
        fontFamily: indicatorIcon.fontFamily,
        package: indicatorIcon.fontPackage,
        color: indicatorColor,
      ),
    );
    iconPainter.layout();

    // Create text painter to measure text dimensions
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: textDirection,
    );
    textPainter.layout();

    final double textHeight = textPainter.height + (textPaddingVertical * 2);
    final double maxHeight = iconPainter.height > textHeight
        ? iconPainter.height
        : textHeight;

    final double centerY = maxHeight / 2;

    iconPainter.paint(
      canvas,
      Offset(
        indicatorX - iconPainter.width / 2,
        centerY - iconPainter.height / 2,
      ),
    );

    _drawTextWithBackground(
      canvas,
      size,
      indicatorX,
      centerY,
      iconPainter.width,
    );
  }

  void _drawTextWithBackground(
    Canvas canvas,
    Size size,
    double indicatorX,
    double centerY,
    double iconWidth,
  ) {
    final bool isRTL = textDirection == TextDirection.rtl;

    TextStyle currentTextStyle = textStyle;
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: currentTextStyle),
      textDirection: textDirection,
    );
    textPainter.layout();

    double textWidth = textPainter.width + (textPaddingHorizontal * 2);
    double textHeight = textPainter.height + (textPaddingVertical * 2);

    // Determine if text should be placed after or before the indicator
    // For RTL: "after" means left, "before" means right
    // For LTR: "after" means right, "before" means left
    final double textAfterX = isRTL
        ? indicatorX - (iconWidth / 2) - textSpacing - textWidth
        : indicatorX + (iconWidth / 2) + textSpacing;
    final double textBeforeX = isRTL
        ? indicatorX + (iconWidth / 2) + textSpacing
        : indicatorX - (iconWidth / 2) - textSpacing - textWidth;

    final bool placeAfter = isRTL
        ? textAfterX >= 0
        : (textAfterX + textWidth) <= size.width;
    double textBackgroundX = placeAfter ? textAfterX : textBeforeX;

    // Check if text doesn't fit in either position
    final double availableSpaceAfter = isRTL
        ? indicatorX - (iconWidth / 2) - textSpacing
        : size.width - textAfterX;
    final double availableSpaceBefore = isRTL
        ? size.width - indicatorX - (iconWidth / 2) - textSpacing
        : indicatorX - (iconWidth / 2) - textSpacing;

    if (textWidth > availableSpaceAfter && textWidth > availableSpaceBefore) {
      // Text doesn't fit on either side, need to scale it down
      final double maxAvailableSpace =
          availableSpaceAfter > availableSpaceBefore
          ? availableSpaceAfter
          : availableSpaceBefore;

      // Calculate scale factor to fit the text (account for padding)
      final double scaleFactor =
          (maxAvailableSpace - (textPaddingHorizontal * 2)) / textPainter.width;

      // Apply the scale factor to the font size (minimum 8.0
      final double originalFontSize = textStyle.fontSize ?? 14.0;
      final double newFontSize = (originalFontSize * scaleFactor).clamp(
        8.0,
        originalFontSize,
      );

      currentTextStyle = textStyle.copyWith(fontSize: newFontSize);
      textPainter = TextPainter(
        text: TextSpan(text: text, style: currentTextStyle),
        textDirection: textDirection,
      );

      textPainter.layout();

      textWidth = textPainter.width + (textPaddingHorizontal * 2);
      textHeight = textPainter.height + (textPaddingVertical * 2);

      final double newTextAfterX = isRTL
          ? indicatorX - (iconWidth / 2) - textSpacing - textWidth
          : indicatorX + (iconWidth / 2) + textSpacing;
      final double newTextBeforeX = isRTL
          ? indicatorX + (iconWidth / 2) + textSpacing
          : indicatorX - (iconWidth / 2) - textSpacing - textWidth;
      final bool newPlaceAfter = isRTL
          ? newTextAfterX >= 0
          : (newTextAfterX + textWidth) <= size.width;
      textBackgroundX = newPlaceAfter ? newTextAfterX : newTextBeforeX;
    }

    _drawRoundedBackground(
      textBackgroundX,
      centerY,
      textHeight,
      textWidth,
      canvas,
    );

    // Draw the text
    textPainter.paint(
      canvas,
      Offset(
        textBackgroundX + textPaddingHorizontal,
        centerY - textPainter.height / 2,
      ),
    );
  }

  void _drawRoundedBackground(
    double textBackgroundX,
    double centerY,
    double textHeight,
    double textWidth,
    Canvas canvas,
  ) {
    final Paint backgroundPaint = Paint()
      ..color = textBackgroundColor
      ..style = PaintingStyle.fill;

    final RRect backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        textBackgroundX,
        centerY - textHeight / 2,
        textWidth,
        textHeight,
      ),
      const Radius.circular(textBorderRadius),
    );

    canvas.drawRRect(backgroundRect, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreIndicatorPainter oldDelegate) =>
      oldDelegate.score != score ||
      oldDelegate.indicatorColor != indicatorColor ||
      oldDelegate.indicatorIcon != indicatorIcon ||
      oldDelegate.text != text ||
      oldDelegate.textBackgroundColor != textBackgroundColor ||
      oldDelegate.textStyle != textStyle;
}
