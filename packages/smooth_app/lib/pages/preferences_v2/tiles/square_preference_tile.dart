import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/autosize_text.dart';

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
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Material(
      color: lightTheme
          ? themeExtension.primaryMedium
          : themeExtension.primaryDark,
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: MEDIUM_SPACE + 1.0,
            bottom: MEDIUM_SPACE,
            start: SMALL_SPACE,
            end: SMALL_SPACE,
          ),
          child: Column(
            spacing: SMALL_SPACE,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SizedBox.square(
                  dimension: 50.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white54,
                        width: 2.0,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: illustration,
                  ),
                ),
              ),
              Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: lightTheme ? themeExtension.primaryDark : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
