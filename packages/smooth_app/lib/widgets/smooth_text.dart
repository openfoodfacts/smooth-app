import 'package:auto_size_text/auto_size_text.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';

/// An extension on [TextStyle] that allows to have "well spaced" variant
extension TextStyleExtension on TextStyle {
  TextStyle get wellSpaced => copyWith(
        height: WellSpacedTextHelper._WELL_SPACED_TEXT_HEIGHT,
      );
}

/// An extension on [DefaultTextStyle] that allows to have "well spaced" variant
extension DefaultTextStyleExtension on DefaultTextStyle {
  TextStyle get wellSpacedTextStyle => style.wellSpaced;
}

/// An extension on [Text] to transform it to [AutoSizeText]
extension TextExtension on Text {
  AutoSizeText toAutoSizeText({
    double? minFontSize,
    double? maxFontSize,
    double? stepGranularity,
    List<double>? presetFontSizes,
    AutoSizeGroup? group,
    bool? wrapWords,
    Widget? overflowReplacement,
  }) =>
      AutoSizeText(
        data!,
        textKey: key,
        style: style,
        strutStyle: strutStyle,
        minFontSize: minFontSize = 12,
        maxFontSize: maxFontSize = double.infinity,
        stepGranularity: stepGranularity = 1,
        presetFontSizes: presetFontSizes,
        group: group,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        wrapWords: wrapWords ?? true,
        overflow: overflow,
        overflowReplacement: overflowReplacement,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
      );
}

class WellSpacedTextHelper {
  const WellSpacedTextHelper._();

  static const double _WELL_SPACED_TEXT_HEIGHT = 1.4;

  static const TextStyle TEXT_STYLE_WITH_WELL_SPACED =
      TextStyle(height: _WELL_SPACED_TEXT_HEIGHT);

  static Widget mergeWithWellSpacedTextStyle({
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    bool? softWrap,
    TextOverflow? overflow,
    int? maxLines,
    TextWidthBasis? textWidthBasis,
    required Widget child,
  }) =>
      DefaultTextStyle.merge(
        child: child,
        key: key,
        style: style ?? const TextStyle(height: _WELL_SPACED_TEXT_HEIGHT),
        textAlign: textAlign,
        softWrap: softWrap,
        overflow: overflow,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis,
      );
}

class TextHighlighter extends StatelessWidget {
  const TextHighlighter({
    required this.text,
    required this.filter,
    this.selected = false,
  });

  final String text;
  final String filter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final List<(String, TextStyle?)> parts = _getParts(
      defaultStyle: TextStyle(fontWeight: selected ? FontWeight.bold : null),
      highlightedStyle: TextStyle(
        fontWeight: selected ? FontWeight.bold : null,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
    );

    final TextStyle defaultTextStyle = DefaultTextStyle.of(context).style;

    return Text.rich(
      TextSpan(
        children: parts.map(((String, TextStyle?) part) {
          return TextSpan(
            text: part.$1,
            style: defaultTextStyle.merge(part.$2),
          );
        }).toList(growable: false),
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }

  /// Returns a List containing parts of the text with the right style
  /// according to the [filter]
  List<(String, TextStyle?)> _getParts({
    required TextStyle? defaultStyle,
    required TextStyle? highlightedStyle,
  }) {
    final Iterable<RegExpMatch> highlightedParts =
        RegExp(removeDiacritics(filter).toLowerCase().trim()).allMatches(
      removeDiacritics(text).toLowerCase(),
    );

    final List<(String, TextStyle?)> parts = <(String, TextStyle?)>[];

    if (highlightedParts.isEmpty) {
      parts.add((text, defaultStyle));
    } else {
      parts
          .add((text.substring(0, highlightedParts.first.start), defaultStyle));
      for (int i = 0; i != highlightedParts.length; i++) {
        final RegExpMatch subPart = highlightedParts.elementAt(i);

        parts.add(
          (text.substring(subPart.start, subPart.end), highlightedStyle),
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
