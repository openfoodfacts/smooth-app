import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class PreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsetsDirectional.all(12.0),
        children: <Widget>[
          const SizedBox(
            height: 80,
          ),
          PreferenceCard(
            title: 'Preferences',
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.settings,
                title: 'Test',
                subtitle: 'Test subtitle',
              ),
              NavigationPreferenceTile(
                icon: Icons.settings,
                title: 'Test',
                subtitle: 'Test subtitle',
              ),
              NavigationPreferenceTile(
                icon: Icons.settings,
                title: 'Test',
                subtitle: 'Test subtitle',
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          PreferenceCard(
            title: 'Preferences',
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.settings,
                title: 'Test',
                subtitle: 'Test subtitle',
              ),
              NavigationPreferenceTile(
                icon: Icons.settings,
                title: 'Test',
                subtitle: 'Test subtitle',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
