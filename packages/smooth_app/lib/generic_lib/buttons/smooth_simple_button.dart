import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothSimpleButton extends StatelessWidget {
  const SmoothSimpleButton({
    required this.child,
    required this.onPressed,
    this.minWidth = 15.0,
    this.height = 20.0,
    this.borderRadius,
    this.padding = const EdgeInsetsDirectional.all(BALANCED_SPACE),
    this.buttonColor,
    this.elevation,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double minWidth;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? buttonColor;
  final WidgetStateProperty<double?>? elevation;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: height,
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: elevation,
          backgroundColor: buttonColor == null
              ? null
              : WidgetStateProperty.all<Color>(buttonColor!),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? ROUNDED_BORDER_RADIUS,
            ),
          ),
          overlayColor: context.read<ThemeProvider>().isAmoledTheme
              ? WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  return states.contains(WidgetState.pressed)
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3)
                      : null;
                })
              : null,
          side: context.read<ThemeProvider>().isAmoledTheme
              ? WidgetStateProperty.all<BorderSide>(
                  const BorderSide(color: Colors.white),
                )
              : null,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
