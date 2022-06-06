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
  final VoidCallback? onPressed;
  final double minWidth;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minWidth: minWidth, minHeight: height),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: buttonColor == null
                ? null
                : MaterialStateProperty.all<Color>(buttonColor!),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: borderRadius),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      );
}
