import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class AppBarAuthenticationButton extends StatelessWidget {
  AppBarAuthenticationButton({
    required this.title,
    required this.onPressed,
    super.key,
  }) : assert(title.isNotEmpty, 'title must not be empty.');

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    final bool lightTheme = context.lightTheme();

    return Material(
      borderRadius: ROUNDED_BORDER_RADIUS,
      child: InkWell(
        onTap: onPressed,
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: lightTheme
                                  ? themeExtension.primaryBlack
                                  : Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        icons.CircledArrow.right(
                          type: icons.CircledArrowType.normal,
                          circleColor: lightTheme
                              ? themeExtension.primaryBlack
                              : Colors.white,
                          color: lightTheme
                              ? Colors.white
                              : themeExtension.primaryBlack,
                          size: 20.0,
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 6.0,
                            vertical: 7.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
