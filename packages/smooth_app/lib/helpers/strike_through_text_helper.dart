import 'package:flutter/material.dart';

class StrikeThroughText extends Text {
  StrikeThroughText(
    super.data, {
    this.strikeThroughType = StrikeThroughTextType.horizontal,
    this.strikeThroughThickness = 1.0,
    this.strikeThroughColor,
    super.key,
    TextStyle? style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  }) : assert(strikeThroughThickness > 0.0),
       super(style: style?.copyWith(decoration: TextDecoration.none));

  final StrikeThroughTextType strikeThroughType;
  final double strikeThroughThickness;
  final Color? strikeThroughColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: strikeThroughType != StrikeThroughTextType.none
          ? _StrikeThroughPainter(
              color:
                  strikeThroughColor ??
                  style?.color ??
                  DefaultTextStyle.of(context).style.color ??
                  Colors.black,
              thickness: strikeThroughThickness,
              height: _computeHeight(),
              type: strikeThroughType,
            )
          : null,
      child: super.build(context),
    );
  }

  double _computeHeight() {
    final TextSpan textSpan = TextSpan(text: data, style: style);

    final TextPainter tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp.height;
  }
}

class _StrikeThroughPainter extends CustomPainter {
  _StrikeThroughPainter({
    required this.color,
    required this.thickness,
    required this.height,
    required this.type,
  });

  final Color color;
  final double thickness;
  final double height;
  final StrikeThroughTextType type;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (type) {
      case StrikeThroughTextType.horizontal:
        canvas.drawLine(
          Offset(0.0, size.height / 2.0 + 1.0),
          Offset(size.width, size.height / 2.0 + 1.0),
          paint,
        );
      case StrikeThroughTextType.topToBottom:
        canvas.drawLine(
          Offset(0.0, size.height - height),
          Offset(size.width, size.height),
          paint,
        );
      case StrikeThroughTextType.bottomToTop:
        canvas.drawLine(
          Offset(0.0, size.height),
          Offset(size.width, size.height - height),
          paint,
        );
      case StrikeThroughTextType.none:
        throw UnimplementedError();
    }
  }

  @override
  bool shouldRepaint(_StrikeThroughPainter oldDelegate) =>
      color != oldDelegate.color || thickness != oldDelegate.thickness;

  @override
  bool shouldRebuildSemantics(_StrikeThroughPainter oldDelegate) => false;
}

enum StrikeThroughTextType { none, horizontal, topToBottom, bottomToTop }
