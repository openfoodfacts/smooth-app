import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class GuidesComingSoonLabel extends StatelessWidget {
  const GuidesComingSoonLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    final Color contentColor;
    if (context.lightTheme()) {
      contentColor = extension.primarySemiDark;
    } else {
      contentColor = extension.primaryAccent;
    }

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: extension.primaryMedium,
          borderRadius: ROUNDED_BORDER_RADIUS,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: BALANCED_SPACE,
            children: <Widget>[
              icons.DangerousZone(color: contentColor),
              Text(
                appLocalizations.guide_coming_soon_button_title,
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
