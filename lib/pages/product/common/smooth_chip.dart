import 'package:flutter/material.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

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
    final Color? foregroundColor = materialColor == null
        ? null
        : SmoothTheme.getColor(
            colorScheme,
            materialColor!,
            ColorDestination.BUTTON_FOREGROUND,
          );
    final Color? backgroundColor = materialColor == null
        ? null
        : SmoothTheme.getColor(
            colorScheme,
            materialColor!,
            ColorDestination.BUTTON_BACKGROUND,
          );
    final Widget? text = label == null
        ? null
        : Text(label!, style: TextStyle(color: foregroundColor));
    final ButtonStyle buttonStyle =
        ElevatedButton.styleFrom(primary: backgroundColor, shape: shape);
    final Icon? icon =
        iconData == null ? null : Icon(iconData, color: foregroundColor);
    if (text == null) {
      return ElevatedButton(
        child: icon,
        onPressed: onPressed,
        style: buttonStyle,
      );
    }
    if (icon == null) {
      return ElevatedButton(
        child: text,
        onPressed: onPressed,
        style: buttonStyle,
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
