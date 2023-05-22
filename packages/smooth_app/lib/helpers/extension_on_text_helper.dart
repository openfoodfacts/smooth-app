import 'package:flutter/material.dart';

extension Selectable on Text {
  Widget selectable({bool isSelectable = true}) {
    return isSelectable
        ? SelectableText(
            data!,
            style: style,
            strutStyle: strutStyle,
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            textAlign: textAlign,
            maxLines: maxLines,
            // TODO(m123): Fix or remove alltogether
            // ignore: deprecated_member_use
            toolbarOptions: const ToolbarOptions(
              copy: true,
              selectAll: true,
            ),
          )
        : Text(
            data!,
            style: style,
            strutStyle: strutStyle,
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            textAlign: textAlign,
            maxLines: maxLines,
          );
  }
}

extension StringExtensions on String {
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
}
