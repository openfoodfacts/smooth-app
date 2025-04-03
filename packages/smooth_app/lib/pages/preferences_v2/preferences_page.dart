import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/onboarding/currency_selector.dart';
import 'package:smooth_app/pages/preferences/country_selector/country_selector.dart';
import 'package:smooth_app/pages/preferences/language_selector/language_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_choose_app_theme.dart';
import 'package:smooth_app/pages/preferences/user_preferences_image_source.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/logged_in_app_bar.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/toggle_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';

class PreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return ChangeNotifierProvider<PreferencesRootSearchController>(
      create: (_) => PreferencesRootSearchController(),
      child: PreferencesRoot(
        appBar: const LoggedInAppBar(),
        cards: <PreferenceCard>[
          PreferenceCard(
            title: 'Général',
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.account_circle,
                title: appLocalizations.myPreferences_profile_title,
                subtitleText: appLocalizations.myPreferences_profile_subtitle,
                root: PreferencesRoot(
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
                root: const PreferencesRoot(
                  cards: <PreferenceCard>[],
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.settings,
                title: appLocalizations.myPreferences_settings_title,
                subtitleText: appLocalizations.myPreferences_settings_subtitle,
                root: PreferencesRoot(
                  cards: <PreferenceCard>[
                    PreferenceCard(
                      title: appLocalizations.settings_app_app,
                      tiles: <PreferenceTile>[
                        PreferenceTile(
                          icon: Icons.telegram,
                          title: appLocalizations.darkmode,
                          subtitle: const UserPreferencesChooseAppTheme(
                            hideTitle: true,
                          ),
                        ),
                        PreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations.country_picker_label,
                          subtitle: const CountrySelector(
                            forceCurrencyChange: false,
                          ),
                        ),
                        PreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations.currency_picker_label,
                          subtitle: CurrencySelector(),
                        ),
                        PreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations.language_picker_label,
                          subtitle: const LanguageSelector(),
                        ),
                        PreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations.choose_image_source_title,
                          subtitle: const UserPreferencesImageSource(
                            hideTitle: true,
                          ),
                        ),
                      ],
                    ),
                    PreferenceCard(
                      title: 'Products',
                      tiles: <PreferenceTile>[
                        TogglePreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations.expand_nutrition_facts,
                          subtitleText:
                              appLocalizations.expand_nutrition_facts_body,
                          state: true,
                          onToggle: (bool value) {
                            // Handle toggle action
                          },
                        ),
                        TogglePreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations.expand_ingredients,
                          subtitleText:
                              appLocalizations.expand_ingredients_body,
                          state: true,
                          onToggle: (bool value) {
                            // Handle toggle action
                          },
                        ),
                        TogglePreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations
                              .search_product_filter_visibility_title,
                          subtitleText: appLocalizations
                              .search_product_filter_visibility_subtitle,
                          state: userPreferences.searchProductTypeFilterVisible,
                          onToggle: (final bool visible) async =>
                              userPreferences
                                  .setSearchProductTypeFilter(visible),
                        ),
                      ],
                    ),
                    PreferenceCard(
                      title: appLocalizations.crash_reporting_toggle_title,
                      tiles: <PreferenceTile>[
                        TogglePreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations.crash_reporting_toggle_title,
                          subtitleText:
                              appLocalizations.crash_reporting_toggle_subtitle,
                          state: true,
                          onToggle: (bool value) {
                            // Handle toggle action
                          },
                        ),
                        TogglePreferenceTile(
                          icon: Icons.public,
                          title: appLocalizations.expand_nutrition_facts,
                          subtitleText:
                              appLocalizations.expand_ingredients_body,
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
            ],
          ),
          PreferenceCard(
            title: 'Le projet Open Food Facts',
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.input,
                title: appLocalizations.contribute,
                subtitleText: 'Traduire, améliorer nos outils...',
                root: const PreferencesRoot(
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
