import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SearchHint extends StatelessWidget {
  const SearchHint({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    final Color color = context.lightTheme()
        ? theme.primaryNormal
        : theme.primaryMedium;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          HintArrowAnimation(size: 70.0, color: color),
          PositionedDirectional(
            top: 50.0,
            start: 30.0,
            end: SMALL_SPACE,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
