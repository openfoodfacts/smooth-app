import 'package:diacritic/diacritic.dart' as lib;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  int count(String character) {
    assert(character.length == 1);

    int count = 0;
    for (int i = 0; i < length; i++) {
      if (this[i] == character) {
        count++;
      }
    }

    return count;
  }

  String firstLetterInUppercase() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}

extension TextScalerExtension on BuildContext {
  /// Returns the text font multiplier
  double textScaler() => MediaQuery.textScalerOf(this).scale(1.0);
}

extension TextSpanExtension on TextSpan {
  TextSpan copyWith({
    TextStyle? style,
    List<InlineSpan>? children,
    String? text,
    GestureRecognizer? recognizer,
    MouseCursor? mouseCursor,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
    String? semanticsLabel,
    Locale? locale,
    bool? spellOut,
  }) => TextSpan(
    style: style ?? this.style,
    children: children ?? this.children,
    text: text ?? this.text,
    recognizer: recognizer ?? this.recognizer,
    mouseCursor: mouseCursor ?? this.mouseCursor,
    onEnter: onEnter ?? this.onEnter,
    onExit: onExit ?? this.onExit,
    semanticsLabel: semanticsLabel ?? this.semanticsLabel,
    locale: locale ?? this.locale,
    spellOut: spellOut ?? this.spellOut,
  );
}

extension Selectable on Text {
  Widget selectable({bool isSelectable = true}) {
    return isSelectable
        ? SelectableText(
            data!,
            style: style,
            strutStyle: strutStyle,
            textDirection: textDirection,
            textScaler: textScaler,
            textAlign: textAlign,
            maxLines: maxLines,
            // TODO(m123): Fix or remove alltogether
            // ignore: deprecated_member_use
            toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
          )
        : Text(
            data!,
            style: style,
            strutStyle: strutStyle,
            textDirection: textDirection,
            textScaler: textScaler,
            textAlign: textAlign,
            maxLines: maxLines,
          );
  }
}
