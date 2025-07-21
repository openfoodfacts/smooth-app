import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class AllStatisticsButton extends StatelessWidget {
  const AllStatisticsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool lightTheme = context.lightTheme();

    return InkWell(
      borderRadius: ROUNDED_BORDER_RADIUS,
      onTap: () {
        Navigator.of(context, rootNavigator: true).push<dynamic>(
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) =>
                const UserPreferencesPage(type: PreferencePageType.ACCOUNT),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: ROUNDED_BORDER_RADIUS,
          color: theme.cardColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              appLocalizations.preferences_app_bar_see_all_stats,
              style: TextStyle(
                color: lightTheme ? theme.primaryColor : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: MEDIUM_SPACE),
            Icon(
              Icons.arrow_circle_right,
              size: 24.0,
              color: lightTheme ? theme.primaryColor : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
