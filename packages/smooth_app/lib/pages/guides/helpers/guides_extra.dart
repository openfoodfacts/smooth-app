import 'package:material_ui/material_ui.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_page.dart';
import 'package:smooth_app/pages/food_preferences/preferences_page_projects.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
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

/// Clickable preference tile in a guide linking to a project's preferences.
class GuidesProjectPreferences extends StatelessWidget {
  const GuidesProjectPreferences({required this.project, super.key});

  final PreferencesPageProjects project;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VERY_LARGE_SPACE,
      ),
      child: ClipRRect(
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: ROUNDED_BORDER_RADIUS,
            border: Border.all(color: theme.colorScheme.primary),
          ),
          child: PreferenceTile(
            leading: project.getLeadingIcon(context.lightTheme()),
            title: project.getTitle(appLocalizations),
            subtitleText: project.getSubtitle(appLocalizations),
            borderRadius: ROUNDED_BORDER_RADIUS,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      FoodPreferencesPage(project: project),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
