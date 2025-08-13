import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/account_deletion_webview.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';

class AccountRoot extends PreferencesRoot {
  const AccountRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_manage_account_title,
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: Icons.person,
            title: appLocalizations.view_profile,
            subtitleText: appLocalizations.preferences_on_off_website_subtitle,
            url: 'https://world.openfoodfacts.org/editor/$userId',
          ),
          UrlPreferenceTile(
            icon: Icons.lock,
            title: appLocalizations.preferences_change_password_title,
            subtitleText: appLocalizations.preferences_on_off_website_subtitle,
            url: 'https://world.openfoodfacts.org/cgi/reset_password.pl',
          ),
          PreferenceTile(
            icon: Icons.logout,
            title: appLocalizations.preferences_app_store,
            subtitleText: GlobalVars.storeLabel.name,
            onTap: () async {
              if (await _confirmLogout(context, appLocalizations) == true) {
                if (context.mounted) {
                  await context.read<UserManagementProvider>().logout();
                  AnalyticsHelper.trackEvent(AnalyticsEvent.logoutAction);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              }
            },
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_danger_zone,
        titleBackgroundColor: Colors.red,
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.delete,
            title: appLocalizations.account_delete,
            subtitleText:
                appLocalizations.preferences_account_deletion_subtitle,
            onTap: () async => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => AccountDeletionWebview(),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Future<bool?> _confirmLogout(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) async => showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return SmoothAlertDialog(
        title: appLocalizations.sign_out,
        body: Text(appLocalizations.sign_out_confirmation),
        positiveAction: SmoothActionButton(
          text: appLocalizations.yes,
          onPressed: () async => Navigator.pop(context, true),
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.no,
          onPressed: () => Navigator.pop(context, false),
        ),
      );
    },
  );
}
