import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class AboutAppRoot extends PreferencesRoot {
  const AboutAppRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_about_information_title,
        tiles: <PreferenceTile>[
          _buildVersionTile(appLocalizations),
          _buildScannerTile(appLocalizations),
          _buildAppStoreTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_title,
        tiles: <PreferenceTile>[_buildSourceCodeTile(appLocalizations)],
      ),
    ];
  }

  @override
  WidgetBuilder? getFooter() => (BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return Padding(
      padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
      child: PreferenceCard(
        title: appLocalizations.preferences_about_app_development_title,
        titleBackgroundColor: context
            .extension<SmoothColorsThemeExtension>()
            .error,
        tiles: <PreferenceTile>[
          _buildDevModeTile(appLocalizations, userPreferences),
        ],
      ),
    );
  };

  // Information section
  PreferenceTile _buildVersionTile(AppLocalizations appLocalizations) {
    return PreferenceTile(
      leading: const icons.Info(),
      title: appLocalizations.preferences_version_number_title,
      subtitle: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox.square(
                  dimension: 12.0,
                  child: CircularProgressIndicator.adaptive(),
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
    );
  }

  PreferenceTile _buildScannerTile(AppLocalizations appLocalizations) {
    return PreferenceTile(
      leading: const icons.Camera.filled(),
      title: appLocalizations.preferences_scanner_title,
      subtitleText: GlobalVars.scannerLabel.name,
    );
  }

  PreferenceTile _buildAppStoreTile(AppLocalizations appLocalizations) {
    return PreferenceTile(
      leading: const icons.AppStore(),
      title: appLocalizations.preferences_app_store,
      subtitleText: GlobalVars.storeLabel.name,
    );
  }

  // Contribute section
  UrlPreferenceTile _buildSourceCodeTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      leading: const icons.GitHub(),
      title: appLocalizations.preferences_source_code,
      subtitleText: appLocalizations.preferences_source_code_subtitle,
      url: 'https://github.com/openfoodfacts/smooth-app',
    );
  }

  // Development section
  TogglePreferenceTile _buildDevModeTile(
    AppLocalizations appLocalizations,
    UserPreferences userPreferences,
  ) {
    return TogglePreferenceTile(
      title: appLocalizations.contribute_develop_dev_mode_title,
      subtitleText: appLocalizations.contribute_develop_dev_mode_subtitle,
      icon: const icons.Contribute(),
      state: userPreferences.devMode != 0,
      onToggle: (final bool devMode) async =>
          userPreferences.setDevMode(devMode ? 1 : 0),
    );
  }
}
