import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/account_deletion_webview.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

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
          _buildViewProfileTile(appLocalizations, userId),
          _buildChangePasswordTile(appLocalizations),
          _buildSignOutTile(context, appLocalizations),
        ],
      ),
    ];
  }

  // Account Management section
  UrlPreferenceTile _buildViewProfileTile(
    AppLocalizations appLocalizations,
    String? userId,
  ) {
    return UrlPreferenceTile(
      leading: const icons.Profile(),
      title: appLocalizations.view_profile,
      subtitleText: appLocalizations.preferences_on_off_website_subtitle,
      url: 'https://world.openfoodfacts.org/editor/$userId',
    );
  }

  UrlPreferenceTile _buildChangePasswordTile(
    AppLocalizations appLocalizations,
  ) {
    return UrlPreferenceTile(
      leading: const icons.Password.lock(),
      title: appLocalizations.preferences_change_password_title,
      subtitleText: appLocalizations.preferences_on_off_website_subtitle,
      url: 'https://world.openfoodfacts.org/cgi/reset_password.pl',
    );
  }

  PreferenceTile _buildSignOutTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: const icons.Logout(),
      title: appLocalizations.sign_out,
      onTap: () async {
        if (await _confirmLogout(context, appLocalizations) == true) {
          if (context.mounted) {
            await context.read<UserManagementProvider>().logout();
            AnalyticsHelper.trackEvent(AnalyticsEvent.logoutAction);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
    );
  }

  @override
  WidgetBuilder getFooter() => (BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
      child: PreferenceCard(
        title: appLocalizations.preferences_danger_zone,
        titleBackgroundColor: Colors.red,
        tiles: <PreferenceTile>[
          _buildAccountDeletionTile(context, appLocalizations),
        ],
      ),
    );
  };

  // Danger Zone section
  PreferenceTile _buildAccountDeletionTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: const icons.Warning(),
      title: appLocalizations.account_delete_title,
      subtitleText: appLocalizations.preferences_account_deletion_subtitle,
      onTap: () async => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => AccountDeletionWebview(),
        ),
      ),
    );
  }

  Future<bool?> _confirmLogout(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) async {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return showSmoothListOfChoicesModalSheet<bool>(
      context: context,
      safeArea: true,
      title: appLocalizations.sign_out,
      header: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: MEDIUM_SPACE,
          ),
          child: Text(
            appLocalizations.sign_out_confirmation,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      labels: <String>[appLocalizations.yes, appLocalizations.no],
      values: <bool>[true, false],
      prefixIcons: <Widget>[
        icons.Check.circled(color: theme.success),
        icons.Close.circled(color: theme.error),
      ],
    );
  }
}
