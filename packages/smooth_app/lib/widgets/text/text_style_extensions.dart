import 'package:flutter/material.dart';

/// An extension on [TextStyle] that allows to have "well spaced" variant
extension TextStyleExtension on TextStyle {
  TextStyle get wellSpaced =>
      copyWith(height: WellSpacedTextHelper._WELL_SPACED_TEXT_HEIGHT);
}

/// An extension on [DefaultTextStyle] that allows to have "well spaced" variant
extension DefaultTextStyleExtension on DefaultTextStyle {
  TextStyle get wellSpacedTextStyle => style.wellSpaced;
}

class WellSpacedTextHelper {
  const WellSpacedTextHelper._();

  static const double _WELL_SPACED_TEXT_HEIGHT = 1.45;

  static const TextStyle TEXT_STYLE_WITH_WELL_SPACED = TextStyle(
    height: _WELL_SPACED_TEXT_HEIGHT,
  );

  static Widget mergeWithWellSpacedTextStyle({
    required Widget child,
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    bool? softWrap,
    TextOverflow? overflow,
    int? maxLines,
    TextWidthBasis? textWidthBasis,
  }) => DefaultTextStyle.merge(
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
