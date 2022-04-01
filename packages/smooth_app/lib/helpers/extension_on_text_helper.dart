import 'package:flutter/material.dart';

extension Selectable on Text {
  Widget selectable({bool isSelectable = true}) {
    return isSelectable
        ? SelectableText(
            data!,
            style: style,
            toolbarOptions: const ToolbarOptions(
              copy: true,
              selectAll: true,
            ),
          )
        : Text(
            data!,
            style: style,
          );
  }
}
