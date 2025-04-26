import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/logged_in_app_bar.dart';
import 'package:smooth_app/pages/preferences_v2/app_bars/logged_out_app_bar.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/app_settings_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/default_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/github_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/wiki_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';

class PreferencesPage extends StatelessWidget {
  String? _getUserId() => OpenFoodAPIConfiguration.globalUser?.userId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    final String? userId = _getUserId();

    return ChangeNotifierProvider<PreferencesRootSearchController>(
      create: (_) => PreferencesRootSearchController(),
      child: DefaultPreferencesRoot(
        customAppBar: userId != null
            ? LoggedInAppBar(userId: userId)
            : const LoggedOutAppBar(),
        cards: <PreferenceCard>[
          PreferenceCard(
            title: appLocalizations.preferences_card_general,
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.account_circle,
                title: appLocalizations.myPreferences_profile_title,
                subtitleText: appLocalizations.myPreferences_profile_subtitle,
                target: const UserPreferencesPage(
                  type: PreferencePageType.ACCOUNT,
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.egg,
                title: appLocalizations.myPreferences_food_title,
                subtitleText: appLocalizations.myPreferences_food_subtitle,
                target: const UserPreferencesPage(
                  type: PreferencePageType.FOOD,
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.euro,
                title: appLocalizations.preferences_prices_title,
                subtitleText: appLocalizations.preferences_prices_subtitle,
                target: const UserPreferencesPage(
                  type: PreferencePageType.PRICES,
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.settings,
                title: appLocalizations.myPreferences_settings_title,
                subtitleText: appLocalizations.myPreferences_settings_subtitle,
                root: AppSettingsRoot(title: appLocalizations.settings_app_app),
              ),
              if (userPreferences.devMode > 0)
                NavigationPreferenceTile(
                  icon: Icons.settings,
                  title: appLocalizations.dev_preferences_screen_title,
                  subtitleText:
                      appLocalizations.dev_preferences_screen_subtitle,
                  target: const UserPreferencesPage(
                    type: PreferencePageType.DEV_MODE,
                  ),
                ),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_project,
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.input,
                title: appLocalizations.preferences_contribute_title,
                subtitleText: appLocalizations.preferences_contribute_subtitle,
                target: const UserPreferencesPage(
                  type: PreferencePageType.CONTRIBUTE,
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.contact_mail,
                title: appLocalizations.preferences_connect_title,
                subtitleText: appLocalizations.preferences_connect_subtitle,
                target: const UserPreferencesPage(
                  type: PreferencePageType.CONNECT,
                ),
              ),
              UrlPreferenceTile(
                icon: Icons.volunteer_activism,
                title: appLocalizations.preferences_support_title,
                subtitleText: appLocalizations.preferences_support_subtitle,
                url: appLocalizations.donate_url,
              ),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_help,
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.support,
                title: appLocalizations.preferences_faq_title,
                subtitleText: appLocalizations.preferences_faq_subtitle,
                target: const UserPreferencesPage(
                  type: PreferencePageType.FAQ,
                ),
              ),
            ],
          ),
        ],
        externalSearchTiles: <ExternalSearchPreferenceTile>[
          WikiSearchPreferenceTile(),
          GithubSearchPreferenceTile(),
        ],
      ),
    );
  }
}
