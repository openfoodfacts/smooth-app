import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';

class AboutAppRoot extends PreferencesRoot {
  const AboutAppRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return <PreferenceCard>[
      PreferenceCard(
        title: 'Information',
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.info,
            title: appLocalizations.preferences_version_number_title,
            subtitle: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return Text(snapshot.data!.version);
                  },
            ),
          ),
          PreferenceTile(
            icon: Icons.camera,
            title: appLocalizations.preferences_scanner_title,
            subtitleText: GlobalVars.scannerLabel.name,
          ),
          PreferenceTile(
            icon: Icons.shopping_bag,
            title: appLocalizations.preferences_app_store,
            subtitleText: GlobalVars.storeLabel.name,
          ),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_title,
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: Icons.code,
            title: appLocalizations.preferences_source_code,
            url: 'https://github.com/openfoodfacts/smooth-app',
          ),
        ],
      ),
    ];
  }
}
