import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';

class UserPreferencesShareWithFriends extends StatelessWidget {
  const UserPreferencesShareWithFriends();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[
        appLocalizations.contribute_share_header,
      ],
      builder: (_) => const UserPreferencesShareWithFriends(),
    );
  }

  @override
  Widget build(BuildContext context) => UserPreferenceListTile(
        title: AppLocalizations.of(context).contribute_share_header,
        leading: Icon(
          key: const Key('settings.share_app'),
          Icons.adaptive.share,
        ),
        showDivider: false,
        onTap: (final BuildContext context) async {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          final ThemeData themeData = Theme.of(context);
          try {
            await Share.share(appLocalizations.contribute_share_content);
          } on PlatformException {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appLocalizations.error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: themeData.colorScheme.background,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: themeData.colorScheme.onBackground,
              ),
            );
          }
        },
      );
}
