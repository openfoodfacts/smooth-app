import 'package:flutter/material.dart';

extension StringExtensions on String {
  /// Returns a list containing all positions of a [charCode]
  /// By default, the case is taken into account.
  /// Set [ignoreCase] to true, to disable the case verification.
  List<int> indexesOf(
    String charCode, {
    bool ignoreCase = false,
  }) {
    assert(charCode.length == 1);
    if (ignoreCase) {
      charCode = charCode.toLowerCase();
    }

    final List<int> positions = <int>[];
    int i = 0;

    for (; i != length; i++) {
      if ((ignoreCase && this[i].toLowerCase() == charCode) ||
          this[i] == charCode) {
        positions.add(i);
      }
    }

    return positions;
  }

  /// Removes a character by giving its position
  String removeCharacterAt(int position) {
    assert(position >= 0 && position < length);
    return substring(0, position) + substring(position + 1);
  }

  String replaceAllIgnoreFirst(Pattern from, String replace) {
    bool isFirst = true;
    return replaceAllMapped(from, (Match match) {
      if (isFirst) {
        isFirst = false;
        return match.input.substring(match.start, match.end);
      } else {
        return replace;
      }
    });
  }
}

class TextHelper {
  const TextHelper._();

  /// Split the text into parts.
  /// Eg: with the symbol '*'
  /// 'Hello *world*!' => [('Hello ', defaultStyle), ('world', highlightedStyle), ('!', defaultStyle)]
  static List<(String, TextStyle?)> getPartsBetweenSymbol({
    required String text,
    required String symbol,
    required int symbolLength,
    required TextStyle? defaultStyle,
    required TextStyle? highlightedStyle,
  }) {
    text = text.replaceAll(r'\n', '\n');

    final Iterable<RegExpMatch> highlightedParts =
        RegExp('$symbol[^$symbol]+$symbol').allMatches(text);

    final List<(String, TextStyle?)> parts = <(String, TextStyle?)>[];

    if (highlightedParts.isEmpty) {
      parts.add((text, defaultStyle));
    } else {
      parts
          .add((text.substring(0, highlightedParts.first.start), defaultStyle));
      for (int i = 0; i != highlightedParts.length; i++) {
        final RegExpMatch subPart = highlightedParts.elementAt(i);

        parts.add(
          (
            text.substring(
                subPart.start + symbolLength, subPart.end - symbolLength),
            highlightedStyle
          ),
        );

        if (i < highlightedParts.length - 1) {
          parts.add((
            text.substring(
                subPart.end, highlightedParts.elementAt(i + 1).start),
            defaultStyle
          ));
        } else if (subPart.end < text.length) {
          parts.add((text.substring(subPart.end, text.length), defaultStyle));
        }
      }
    }
    return parts;
  }
}

class FormattedText extends StatelessWidget {
  const FormattedText({
    required this.text,
    this.textStyle,
    this.textAlign,
  });

  final String text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultTextStyle = textStyle ?? const TextStyle();
    return Semantics(
      value: text.replaceAll(r'**', '').replaceAll('\n', ' '),
      excludeSemantics: true,
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: TextHelper.getPartsBetweenSymbol(
                  text: text,
                  symbol: r'\*\*',
                  symbolLength: 2,
                  defaultStyle: defaultTextStyle,
                  highlightedStyle:
                      const TextStyle(fontWeight: FontWeight.bold))
              .map(
            ((String, TextStyle?) part) {
              return TextSpan(
                text: part.$1,
                style: defaultTextStyle.merge(part.$2),
                semanticsLabel: '-',
              );
            },
          ).toList(growable: false),
        ),
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}
