import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';

class PreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PreferencesRoot(
      cards: <PreferenceCard>[
        PreferenceCard(
          title: 'Général',
          tiles: <PreferenceTile>[
            NavigationPreferenceTile(
              icon: Icons.account_circle,
              title: 'Mon compte',
              subtitle: 'Modifier mon profile, se déconnecter...',
              root: const PreferencesRoot(
                cards: <PreferenceCard>[],
              ),
            ),
            NavigationPreferenceTile(
              icon: Icons.egg,
              title: 'Mes préférences alimentaires',
              subtitle: 'Allergies, qualité nutritionnelle...',
              root: const PreferencesRoot(
                cards: <PreferenceCard>[],
              ),
            ),
            NavigationPreferenceTile(
              icon: Icons.settings_applications,
              title: "Paramètres de l'application",
              subtitle: 'Mode sombre, langue...',
              root: const PreferencesRoot(
                cards: <PreferenceCard>[],
              ),
            ),
          ],
        ),
        PreferenceCard(
          title: 'Le projet Open Food Facts',
          tiles: <PreferenceTile>[
            NavigationPreferenceTile(
              icon: Icons.input,
              title: 'Contribuer au projet',
              subtitle: 'Traduire, améliorer nos outils...',
              root: const PreferencesRoot(
                cards: <PreferenceCard>[],
              ),
            ),
            TogglePreferenceTile(
              icon: Icons.support,
              title: 'Nous soutenir',
              subtitle: 'Envoyer un don...',
              state: true,
              onToggle: (bool value) {
                // Handle toggle action
              },
            ),
          ],
        ),
        PreferenceCard(
          title: 'Site web',
          tiles: <PreferenceTile>[
            UrlPreferenceTile(
              icon: Icons.web,
              title: "Page d'accueil",
              subtitle: "Visiter le site web d'Open Food Facts",
              url: 'https://world.openfoodfacts.org/',
            ),
          ],
        ),
      ],
    );
  }
}
