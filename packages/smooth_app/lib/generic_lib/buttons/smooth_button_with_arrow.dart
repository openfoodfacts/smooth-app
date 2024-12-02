import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class SmoothButtonWithArrow extends StatelessWidget {
  const SmoothButtonWithArrow({
    required this.text,
    required this.onTap,
    super.key,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(theme.primarySemiDark),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsetsDirectional.symmetric(
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
                style: const TextStyle(
                  color: Colors.white,
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
                color: theme.orange,
              ),
              padding: const EdgeInsetsDirectional.all(VERY_SMALL_SPACE),
              child: const icons.Arrow.right(
                color: Colors.white,
                size: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
