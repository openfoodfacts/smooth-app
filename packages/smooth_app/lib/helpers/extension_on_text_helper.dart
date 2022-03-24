import 'package:flutter/material.dart';

extension Selectable on Text {
  Widget selectable() {
    return SelectableText(
      data!,
      style: style,
      toolbarOptions: const ToolbarOptions(
        copy: true,
        selectAll: true,
      ),
    );
  }
}
