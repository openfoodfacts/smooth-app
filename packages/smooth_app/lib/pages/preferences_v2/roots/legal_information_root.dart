import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';

class LegalInformationRoot extends PreferencesRoot {
  const LegalInformationRoot({required super.title});

  static const String _iconLightAssetPath =
      'assets/app/release_icon_light_transparent_no_border.svg';
  static const String _iconDarkAssetPath =
      'assets/app/release_icon_dark_transparent_no_border.svg';

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final String logo = Theme.of(context).brightness == Brightness.light
        ? _iconLightAssetPath
        : _iconDarkAssetPath;

    return <PreferenceCard>[
      PreferenceCard(
        title: 'Open Food Facts',
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: Icons.file_open,
            title: appLocalizations.preferences_terms_of_use,
            url: 'https://world.openfoodfacts.org/terms-of-use',
          ),
          UrlPreferenceTile(
            icon: Icons.file_open,
            title: appLocalizations.preferences_legal_mentions,
            url: 'https://world.openfoodfacts.org/legal',
          ),
          UrlPreferenceTile(
            icon: Icons.file_open,
            title: appLocalizations.preferences_privacy_policy,
            url: 'https://world.openfoodfacts.org/privacy',
          ),
          PreferenceTile(
            icon: Icons.file_open,
            title: appLocalizations.preferences_licenses,
            onTap: () async {
              final PackageInfo packageInfo = await PackageInfo.fromPlatform();

              if (!context.mounted) {
                return;
              }

              showLicensePage(
                context: context,
                applicationName: packageInfo.appName,
                applicationVersion: packageInfo.version,
                applicationIcon: SvgPicture.asset(
                  logo,
                  height: MediaQuery.sizeOf(context).height * 0.1,
                ),
              );
            },
          ),
        ],
      ),
    ];
  }
}
