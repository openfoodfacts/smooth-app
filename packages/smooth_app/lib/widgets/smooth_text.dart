import 'package:diacritic/diacritic.dart' as lib show removeDiacritics;
import 'package:flutter/material.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// An extension on [String]
extension StringExtension on String {
  /// Please use this method instead of directly calling the library.
  /// It will ease the migration if we decide to remove/change it.
  String removeDiacritics() {
    return lib.removeDiacritics(this);
  }

  /// Same as [removeDiacritics] but also lowercases the string.
  /// Prefer this method when you want to compare two strings.
  String getComparisonSafeString() {
    return toLowerCase().removeDiacritics();
  }
}

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
    this.textAlign,
    this.selected = false,
    this.softWrap = false,
  });

  final String text;
  final String filter;
  final TextAlign? textAlign;
  final bool? softWrap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    List<(String, TextStyle?)> parts;
    try {
      parts = _getParts(
        defaultStyle: TextStyle(fontWeight: selected ? FontWeight.bold : null),
        highlightedStyle: TextStyle(
          fontWeight: selected ? FontWeight.bold : null,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      );
    } catch (e, trace) {
      parts = <(String, TextStyle?)>[(text, null)];
      Logs.e(
        'Unable to parse text "$text" with filter "$filter".',
        ex: e,
        stacktrace: trace,
      );
    }

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
      softWrap: softWrap,
      textAlign: textAlign,
      overflow: TextOverflow.fade,
    );
  }

  /// Returns a List containing parts of the text with the right style
  /// according to the [filter]
  List<(String, TextStyle?)> _getParts({
    required TextStyle? defaultStyle,
    required TextStyle? highlightedStyle,
  }) {
    final String filterWithoutDiacritics = filter.getComparisonSafeString();
    final String textWithoutDiacritics = text.getComparisonSafeString();

    final Iterable<RegExpMatch> highlightedParts =
        RegExp(RegExp.escape(filterWithoutDiacritics.trim())).allMatches(
      textWithoutDiacritics,
    );

    final List<(String, TextStyle?)> parts = <(String, TextStyle?)>[];

    if (highlightedParts.isEmpty) {
      parts.add((text, defaultStyle));
    } else {
      parts
          .add((text.substring(0, highlightedParts.first.start), defaultStyle));
      int diff = 0;

      for (int i = 0; i != highlightedParts.length; i++) {
        final RegExpMatch subPart = highlightedParts.elementAt(i);
        final int startPosition = subPart.start - diff;
        final int endPosition = _computeEndPosition(
          startPosition,
          subPart.end - diff,
          subPart,
          textWithoutDiacritics,
          filterWithoutDiacritics,
        );
        diff = subPart.end - endPosition;

        parts.add(
          (text.substring(startPosition, endPosition), highlightedStyle),
        );

        if (i < highlightedParts.length - 1) {
          parts.add((
            text.substring(
                endPosition, highlightedParts.elementAt(i + 1).start - diff),
            defaultStyle
          ));
        } else if (endPosition < text.length) {
          parts.add((text.substring(endPosition, text.length), defaultStyle));
        }
      }
    }
    return parts;
  }

  int _computeEndPosition(
    int startPosition,
    int endPosition,
    RegExpMatch subPart,
    String textWithoutDiacritics,
    String filterWithoutDiacritics,
  ) {
    final String subText = text.substring(startPosition);
    if (subText.startsWith(filterWithoutDiacritics)) {
      return endPosition;
    }

    int diff = 0;
    for (int pos = 0; pos < endPosition; pos++) {
      if (pos == subText.length - 1) {
        diff = pos - subText.length;
        break;
      }

      final int charLength = subText[pos].removeDiacritics().length;
      diff -= charLength > 1 ? charLength - 1 : 0;
    }

    return endPosition + diff;
  }
}

class HighlightedTextSpan extends WidgetSpan {
  HighlightedTextSpan({
    required String text,
    required TextStyle textStyle,
    required EdgeInsetsGeometry padding,
    required Color backgroundColor,
    required double radius,
    EdgeInsetsGeometry? margin,
  })  : assert(radius > 0.0),
        super(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(
                Radius.circular(radius),
              ),
            ),
            margin: margin,
            padding: padding,
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        );
}
