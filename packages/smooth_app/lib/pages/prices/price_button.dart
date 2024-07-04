import 'package:flutter/material.dart';

/// Simple price button: displaying data with optional action.
class PriceButton extends StatelessWidget {
  const PriceButton({
    this.title,
    this.iconData,
    this.buttonStyle,
    this.tooltip,
    required this.onPressed,
  });

  final String? title;
  final IconData? iconData;
  final ButtonStyle? buttonStyle;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget widget;

    if (iconData == null) {
      widget = ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(title!),
      );
    } else if (title == null) {
      widget = ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Icon(iconData),
      );
    } else {
      widget = ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(iconData),
        label: Text(title!),
        style: buttonStyle,
      );
    }

    if (tooltip?.isNotEmpty == true) {
      return Semantics(
        value: tooltip,
        button: true,
        excludeSemantics: true,
        child: Tooltip(
          message: tooltip,
          child: widget,
        ),
      );
    }
    return widget;
  }
}
