import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/logged_in_app_bar.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/app_settings_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';

class PreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ChangeNotifierProvider<PreferencesRootSearchController>(
      create: (_) => PreferencesRootSearchController(),
      child: DefaultPreferencesRoot(
        customAppBar: const LoggedInAppBar(),
        cards: <PreferenceCard>[
          PreferenceCard(
            title: 'Général',
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.account_circle,
                title: appLocalizations.myPreferences_profile_title,
                subtitleText: appLocalizations.myPreferences_profile_subtitle,
                root: DefaultPreferencesRoot(
                  title: appLocalizations.myPreferences_profile_title,
                  cards: <PreferenceCard>[
                    PreferenceCard(
                      title: 'Mon profil',
                      tiles: <PreferenceTile>[
                        TogglePreferenceTile(
                          icon: Icons.public,
                          title: 'Profil public',
                          subtitleText:
                              'Afficher mon profil aux autres utilisateurs',
                          state: true,
                          onToggle: (bool value) {
                            // Handle toggle action
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.egg,
                title: appLocalizations.myPreferences_food_title,
                subtitleText: appLocalizations.myPreferences_food_subtitle,
                root: const DefaultPreferencesRoot(
                  cards: <PreferenceCard>[],
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.settings,
                title: appLocalizations.myPreferences_settings_title,
                subtitleText: appLocalizations.myPreferences_settings_subtitle,
                root: const AppSettingsRoot(title: 'Settings'),
              ),
            ],
          ),
          PreferenceCard(
            title: 'Le projet Open Food Facts',
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.input,
                title: appLocalizations.contribute,
                subtitleText: 'Traduire, améliorer nos outils...',
                root: const DefaultPreferencesRoot(
                  cards: <PreferenceCard>[],
                ),
              ),
              UrlPreferenceTile(
                icon: Icons.volunteer_activism,
                title: 'Nous soutenir',
                subtitleText: 'Envoyer un don...',
                url: appLocalizations.donate_url,
              ),
            ],
          ),
          const PreferenceCard(
            title: 'Aide et support',
            tiles: <PreferenceTile>[
              UrlPreferenceTile(
                icon: Icons.support,
                title: 'Aide et support',
                subtitleText: "Visiter la page d'aide et support",
                url: 'https://world.openfoodfacts.org/',
              ),
            ],
          ),
          const PreferenceCard(
            title: 'Site web',
            tiles: <PreferenceTile>[
              UrlPreferenceTile(
                icon: Icons.web,
                title: "Page d'accueil",
                subtitleText: "Visiter le site web d'Open Food Facts",
                url: 'https://world.openfoodfacts.org/',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
