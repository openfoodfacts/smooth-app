import 'package:diacritic/diacritic.dart' as lib show removeDiacritics;
import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/strings_helper.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

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

  static const double _WELL_SPACED_TEXT_HEIGHT = 1.45;

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
    this.textStyle,
  });

  final String text;
  final String filter;
  final TextAlign? textAlign;
  final bool? softWrap;
  final bool selected;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    List<(String, TextStyle?)> parts;
    try {
      final TextStyle defaultStyle =
          textStyle ?? TextStyle(fontWeight: selected ? FontWeight.bold : null);
      parts = _getParts(
        defaultStyle: defaultStyle,
        highlightedStyle: defaultStyle.copyWith(
          backgroundColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.2),
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

/// A Text where parts between "**" are in bold
class TextWithBoldParts extends StatelessWidget {
  const TextWithBoldParts({
    required this.text,
    this.textStyle,
    this.highlightedTextStyle,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final TextStyle? textStyle;
  final TextStyle? highlightedTextStyle;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultTextStyle = textStyle ?? const TextStyle();
    return Semantics(
      value: text.replaceAll(r'**', '').replaceAll('\n', ' '),
      excludeSemantics: true,
      child: RichText(
        textScaler: MediaQuery.textScalerOf(context),
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: TextHelper.getPartsBetweenSymbol(
            text: text,
            symbol: r'\*\*',
            symbolLength: 2,
            defaultStyle: defaultTextStyle,
            highlightedStyle: highlightedTextStyle ??
                const TextStyle(fontWeight: FontWeight.bold),
          ).map(
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
        overflow: overflow ?? TextOverflow.clip,
        maxLines: maxLines,
      ),
    );
  }
}

/// A Text where parts between "__" are underlined
class TextWithUnderlinedParts extends StatelessWidget {
  const TextWithUnderlinedParts({
    required this.text,
    this.textStyle,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultTextStyle = textStyle ?? const TextStyle();

    return Semantics(
      value: text.replaceAll(r'__', '').replaceAll('\n', ' '),
      excludeSemantics: true,
      child: RichText(
        textScaler: MediaQuery.textScalerOf(context),
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: TextHelper.getPartsBetweenSymbol(
            text: text,
            symbol: r'\_\_',
            symbolLength: 2,
            defaultStyle: defaultTextStyle,
            highlightedStyle: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          ).map(
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
        overflow: overflow ?? TextOverflow.clip,
        maxLines: maxLines,
      ),
    );
  }
}

/// A Text where parts between "**" are highlighted in bubbles
class TextWithBubbleParts extends StatelessWidget {
  const TextWithBubbleParts({
    required this.text,
    this.backgroundColor,
    this.fontMultiplier,
    this.textAlign,
    this.textStyle,
    this.bubbleTextStyle,
    this.bubblePadding,
    this.margin,
    super.key,
  });

  final String text;
  final double? fontMultiplier;
  final Color? backgroundColor;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final TextStyle? bubbleTextStyle;
  final EdgeInsetsGeometry? bubblePadding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = this.backgroundColor ??
        context.extension<SmoothColorsThemeExtension>().orange;

    return RichText(
      textScaler: MediaQuery.textScalerOf(context),
      text: TextSpan(
        children: _extractChunks().map(((String text, bool highlighted) el) {
          if (el.$2) {
            return _createSpan(
              el.$1,
              bubblePadding,
              bubbleTextStyle ?? textStyle?.merge(bubbleTextStyle),
              backgroundColor,
            );
          } else {
            return TextSpan(text: el.$1);
          }
        }).toList(growable: false),
        style: DefaultTextStyle.of(context).style.merge(textStyle),
      ),
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  Iterable<(String, bool)> _extractChunks() {
    final Iterable<RegExpMatch> matches =
        RegExp(r'\*\*(.*?)\*\*').allMatches(text);

    if (matches.isEmpty) {
      return <(String, bool)>[(text, false)];
    }

    final List<(String, bool)> chunks = <(String, bool)>[];

    int lastMatch = 0;

    for (final RegExpMatch match in matches) {
      if (matches.first.start > 0) {
        chunks.add((text.substring(lastMatch, match.start), false));
      }

      chunks.add((text.substring(match.start + 2, match.end - 2), true));
      lastMatch = match.end;
    }

    if (lastMatch < text.length) {
      chunks.add((text.substring(lastMatch), false));
    }

    return chunks;
  }

  WidgetSpan _createSpan(
    String text,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Color backgroundColor,
  ) =>
      HighlightedTextSpan(
        text: text,
        textStyle: textStyle ??
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
        padding: padding ??
            const EdgeInsetsDirectional.only(
              top: 2.0,
              bottom: 2.0,
              start: 15.0,
              end: 15.0,
            ),
        margin: margin ?? const EdgeInsetsDirectional.symmetric(vertical: 2.5),
        backgroundColor: backgroundColor,
        radius: 30.0,
      );
}

typedef TextStyleProvider = TextStyle Function(double multiplier);
