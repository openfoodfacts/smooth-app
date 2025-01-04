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

  static const IconData priceIconData = Icons.label;
  static const IconData userIconData = Icons.account_box;
  static const IconData proofIconData = Icons.image;
  static const IconData locationIconData = Icons.location_on;
  static const IconData historyIconData = Icons.history;
  static const IconData productIconData = Icons.category;
  static const IconData warningIconData = Icons.warning;

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
