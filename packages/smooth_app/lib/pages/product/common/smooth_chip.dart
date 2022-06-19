import 'package:flutter/material.dart';

/// Typical action button for Smoothie
class SmoothChip extends StatelessWidget {
  const SmoothChip({
    required this.onPressed,
    this.iconData,
    this.label,
    this.materialColor,
    this.shape,
  });

  final VoidCallback onPressed;
  final IconData? iconData;
  final String? label;
  final MaterialColor? materialColor;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foregroundColor = colorScheme.onPrimaryContainer;
    final Color backgroundColor = colorScheme.primaryContainer;
    final Widget? text = label == null
        ? null
        : Text(label!, style: TextStyle(color: foregroundColor));
    final ButtonStyle buttonStyle =
        ElevatedButton.styleFrom(primary: backgroundColor, shape: shape);
    final Icon? icon =
        iconData == null ? null : Icon(iconData, color: foregroundColor);
    if (text == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: icon,
      );
    }
    if (icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: text,
      );
    }
    return ElevatedButton.icon(
      icon: icon,
      label: text,
      onPressed: onPressed,
      style: buttonStyle,
    );
  }
}
