import 'package:flutter/material.dart';

/// Simple price button: displaying data with optional action.
class PriceButton extends StatelessWidget {
  const PriceButton({
    this.title,
    this.iconData,
    this.buttonStyle,
    required this.onPressed,
  });

  final String? title;
  final IconData? iconData;
  final ButtonStyle? buttonStyle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (iconData == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(title!),
      );
    }
    if (title == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Icon(iconData),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(iconData),
      label: Text(title!),
      style: buttonStyle,
    );
  }
}
