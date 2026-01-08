import 'package:flutter/material.dart';

class KnowledgePanelTitle extends StatelessWidget {
  const KnowledgePanelTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final RegExp parenthesesPattern = RegExp(r'\s*\([^)]+\)\s*$');
    final Match? match = parenthesesPattern.firstMatch(title);

    if (match != null) {
      final String mainText = title.substring(0, match.start).trim();
      final String parenthesesText = match.group(0)!.trim();

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final TextStyle textStyle = DefaultTextStyle.of(context).style;
          final TextPainter textPainter = TextPainter(
            text: TextSpan(text: mainText, style: textStyle),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: constraints.maxWidth);

          if (!textPainter.didExceedMaxLines) {
            return RichText(
              text: TextSpan(
                style: textStyle,
                children: <TextSpan>[
                  TextSpan(text: mainText),
                  TextSpan(text: '\n$parenthesesText'),
                ],
              ),
            );
          } else {
            return Text(title);
          }
        },
      );
    }

    return Text(title);
  }
}
