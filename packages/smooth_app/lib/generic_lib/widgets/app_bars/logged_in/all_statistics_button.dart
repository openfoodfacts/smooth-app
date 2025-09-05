import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/roots/contributions_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class AllStatisticsButton extends StatelessWidget {
  const AllStatisticsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool lightTheme = context.lightTheme();

    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<Widget>(
            builder: (_) =>
                ChangeNotifierProvider<PreferencesRootSearchController>(
                  create: (_) => PreferencesRootSearchController(),
                  child: ContributionsRoot(title: appLocalizations.contribute),
                ),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(12.0),
        color: theme.cardColor,
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
