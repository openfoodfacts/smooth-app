import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SmoothSimpleButton extends StatelessWidget {
  const SmoothSimpleButton({
    required this.child,
    required this.onPressed,
    this.minWidth = 15,
    this.height = 20,
    this.borderRadius = ROUNDED_BORDER_RADIUS,
    this.padding = const EdgeInsets.all(10),
    this.buttonColor,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double minWidth;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return MaterialButton(
      color: buttonColor ?? themeData.colorScheme.primary,
      child: Padding(
        padding: padding,
        child: child,
      ),
      height: height,
      minWidth: minWidth,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      onPressed: () => onPressed(),
    );
  }
}
