import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/roots/contributions_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class AllStatisticsButton extends StatelessWidget {
  const AllStatisticsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final BorderRadius borderRadius = BorderRadius.circular(12.0);

    return Material(
      borderRadius: borderRadius,
      color: Colors.white,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<Widget>(
              builder: (_) =>
                  ChangeNotifierProvider<PreferencesRootSearchController>(
                    create: (_) => PreferencesRootSearchController(),
                    child: ContributionsRoot(
                      title: appLocalizations.contribute,
                    ),
                  ),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              appLocalizations.preferences_app_bar_see_all_stats,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: MEDIUM_SPACE),
            SizedBox.square(
              dimension: 24.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const icons.Arrow.right(color: Colors.white, size: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
