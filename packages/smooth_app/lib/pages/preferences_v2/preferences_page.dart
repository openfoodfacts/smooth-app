import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/logged_in_app_bar.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/logged_out_app_bar.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/hunger_games/question_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/cards/headers/new_nutriscore_header.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/about_app_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/app_settings_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/connect_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/contribute_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/contributions_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/default_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/dev_mode_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/faq_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/legal_information_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/roots/prices_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/forum_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/github_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/wiki_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/square_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';

class PreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    context.watch<UserManagementProvider>();

    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;

    return ChangeNotifierProvider<PreferencesRootSearchController>(
      create: (_) => PreferencesRootSearchController(),
      child: DefaultPreferencesRoot(
        customAppBar: userId != null
            ? LoggedInAppBar(userId: userId)
            : const LoggedOutAppBar(),
        cards: <PreferenceCard>[
          PreferenceCard(
            title: appLocalizations.contribute,
            gridView: true,
            tiles: <PreferenceTile>[
              SquarePreferenceTile(
                title: appLocalizations.preferences_add_prices,
                illustration: SvgPicture.asset(
                  'assets/preferences/prices_contribution.svg',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (BuildContext context) =>
                          ChangeNotifierProvider<
                            PreferencesRootSearchController
                          >(
                            create: (_) => PreferencesRootSearchController(),
                            child: const PricesRoot(title: 'Prices'),
                          ),
                    ),
                  );
                },
              ),
              SquarePreferenceTile(
                title: 'Hunger Games',
                illustration: SvgPicture.asset(
                  'assets/preferences/hunger_games_contribution.svg',
                ),
                onTap: () async {
                  AnalyticsHelper.trackEvent(AnalyticsEvent.hungerGameOpened);

                  await Navigator.push<int>(
                    context,
                    MaterialPageRoute<int>(
                      builder: (BuildContext context) => const QuestionsPage(),
                    ),
                  );
                },
              ),
              SquarePreferenceTile(
                title: appLocalizations.preferences_complete_products,
                illustration: SvgPicture.asset(
                  'assets/preferences/products_contribution.svg',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (BuildContext context) =>
                          ChangeNotifierProvider<
                            PreferencesRootSearchController
                          >(
                            create: (_) => PreferencesRootSearchController(),
                            child: ContributionsRoot(
                              title: appLocalizations
                                  .preferences_contributions_title,
                            ),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
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
                  root: DevModeRoot(
                    title: appLocalizations.dev_preferences_screen_title,
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
                root: ContributeRoot(
                  title: appLocalizations.preferences_contribute_title,
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.contact_mail,
                title: appLocalizations.preferences_connect_title,
                subtitleText: appLocalizations.preferences_connect_subtitle,
                root: ConnectRoot(
                  title: appLocalizations.preferences_connect_title,
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
            header: NewNutriscoreHeader(),
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.support,
                title: appLocalizations.preferences_faq_title,
                subtitleText: appLocalizations.preferences_faq_subtitle,
                root: FaqRoot(title: appLocalizations.preferences_faq_title),
              ),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_about,
            tiles: <PreferenceTile>[
              NavigationPreferenceTile(
                icon: Icons.support,
                title: appLocalizations.preferences_legal_information_title,
                subtitleText:
                    appLocalizations.preferences_legal_information_subtitle,
                root: LegalInformationRoot(
                  title: appLocalizations.preferences_legal_information_title,
                ),
              ),
              NavigationPreferenceTile(
                icon: Icons.support,
                title: appLocalizations.preferences_about_app_title,
                subtitleText: appLocalizations.preferences_about_app_subtitle,
                root: AboutAppRoot(
                  title: appLocalizations.preferences_about_app_title,
                ),
              ),
            ],
          ),
        ],
        externalSearchTiles: <ExternalSearchPreferenceTile>[
          WikiSearchPreferenceTile(),
          GithubSearchPreferenceTile(),
          const ForumSearchPreferenceTile(),
        ],
      ),
    );
  }
}
