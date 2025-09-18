import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SquarePreferenceTile extends PreferenceTile {
  const SquarePreferenceTile({
    required super.title,
    required this.illustration,
    this.autoSizeGroup,
    super.onTap,
  });

  final Widget illustration;
  final AutoSizeGroup? autoSizeGroup;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    final bool lightTheme = context.lightTheme();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: lightTheme
            ? themeExtension.primaryMedium
            : const Color(0xFF333333),
        borderRadius: ROUNDED_BORDER_RADIUS,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: ROUNDED_BORDER_RADIUS,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
            child: Column(
              spacing: SMALL_SPACE,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white54,
                            width: 2.0,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: illustration,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: AutoSizeText(
                          title,
                          group: autoSizeGroup,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: lightTheme
                                ? theme.primaryColor
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
