import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// A button with the following layout:
///   TEXT →
class SmoothButtonWithArrow extends StatelessWidget {
  const SmoothButtonWithArrow({
    required this.text,
    required this.onTap,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.arrowColor,
    super.key,
  });

  final String text;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? arrowColor;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(
            backgroundColor ?? theme.primarySemiDark,
          ),
          padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
            padding ??
                const EdgeInsetsDirectional.symmetric(
                  vertical: SMALL_SPACE,
                  horizontal: LARGE_SPACE,
                ),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: CIRCULAR_BORDER_RADIUS,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 3.0),
              child: Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: MEDIUM_SPACE),
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: arrowColor ?? theme.orange,
              ),
              padding: const EdgeInsetsDirectional.all(VERY_SMALL_SPACE),
              child: icons.Arrow.right(
                color: textColor ?? Colors.white,
                size: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
