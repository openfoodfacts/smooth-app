import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mailto/mailto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Display of "Connect" for the preferences page.
class UserPreferencesConnect extends AbstractUserPreferences {
  UserPreferencesConnect({
    required final Function(Function()) setState,
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
  }) : super(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  @override
  PreferencePageType? getPreferencePageType() => PreferencePageType.CONNECT;

  @override
  String getTitleString() => appLocalizations.connect_with_us;

  @override
  Widget? getSubtitle() => null;

  @override
  List<Widget> getBody() => <Widget>[
        _getListTile(
          title: appLocalizations.instagram,
          url: 'https://instagram.com/open.food.facts',
        ),
        _getListTile(
          title: appLocalizations.twitter,
          url: 'https://www.twitter.com/openfoodfacts',
        ),
        _getListTile(
          title: appLocalizations.blog,
          url: 'https://en.blog.openfoodfacts.org',
        ),
        _getListTile(
          title: appLocalizations.support_join_slack,
          url: 'https://slack.openfoodfacts.org/',
        ),
        _getListTile(
          title: appLocalizations.support_via_email,
          onTap: () async {
            final PackageInfo packageInfo = await PackageInfo.fromPlatform();
            final Mailto mailtoLink = Mailto(
              to: <String>['contact@openfoodfacts.org'],
// This shouldn't be translated as its a debug message to OpenFoodFacts
              subject: 'Smoothie help',
              body:
                  'Version:${packageInfo.version}+${packageInfo.buildNumber} running on ${Platform.operatingSystem}(${Platform.operatingSystemVersion})',
            );
            await launchUrl(Uri.parse('$mailtoLink'));
          },
        ),
      ];

  Widget _getListTile({
    required final String title,
    final String? url,
    final VoidCallback? onTap,
  }) =>
      UserPreferencesListTile(
        title: Text(title, style: themeData.textTheme.headline4),
        onTap: onTap ?? () async => LaunchUrlHelper.launchURL(url!, false),
        icon: const Icon(Icons.open_in_new),
      );
}
