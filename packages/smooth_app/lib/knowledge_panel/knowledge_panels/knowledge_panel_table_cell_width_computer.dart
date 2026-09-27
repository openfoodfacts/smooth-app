import 'package:flutter/material.dart';

class KnowledgePanelTableCellWidthComputer {
  KnowledgePanelTableCellWidthComputer({
    required this.textScaler,
    required this.textStyle,
    required this.headerTextStyle,
  });

  late final TextScaler textScaler;
  late final TextStyle textStyle;
  late final TextStyle headerTextStyle;

  // cf. https://stackoverflow.com/questions/52659759/how-can-i-get-the-size-of-the-text-widget-in-flutter
  Size computeTextSize(String text, TextStyle textStyle) => (TextPainter(
    text: TextSpan(text: text, style: textStyle),
    maxLines: 1,
    textScaler: textScaler,
    // TODO(monsieurtanuki): does it matter?
    textDirection: TextDirection.ltr,
  )..layout()).size;
}
