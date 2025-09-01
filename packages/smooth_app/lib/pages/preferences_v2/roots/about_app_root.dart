import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart';

class AboutAppRoot extends PreferencesRoot {
  const AboutAppRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_about_information_title,
        tiles: <PreferenceTile>[
          PreferenceTile(
            leading: const Info(),
            title: appLocalizations.preferences_version_number_title,
            subtitle: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Row(
                        mainAxisSize: MainAxisSize.max,

                        children: <Widget>[
                          SizedBox(
                            width: 12.0,
                            height: 12.0,
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return Text(snapshot.data!.version);
                  },
            ),
          ),
          PreferenceTile(
            leading: const Camera.filled(),
            title: appLocalizations.preferences_scanner_title,
            subtitleText: GlobalVars.scannerLabel.name,
          ),
          PreferenceTile(
            leading: const AppStore(),
            title: appLocalizations.preferences_app_store,
            subtitleText: GlobalVars.storeLabel.name,
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_title,
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            leading: const GitHub(),
            title: appLocalizations.preferences_source_code,
            subtitleText: appLocalizations.preferences_source_code_subtitle,
            url: 'https://github.com/openfoodfacts/smooth-app',
          ),
        ],
      ),
      PreferenceCard(
        title: 'Development',
        tiles: <PreferenceTile>[
          TogglePreferenceTile(
            title: appLocalizations.contribute_develop_dev_mode_title,
            subtitleText: appLocalizations.contribute_develop_dev_mode_subtitle,
            state: userPreferences.devMode != 0,
            onToggle: (final bool devMode) async =>
                userPreferences.setDevMode(devMode ? 1 : 0),
          ),
        ],
      ),
    ];
  }
}
