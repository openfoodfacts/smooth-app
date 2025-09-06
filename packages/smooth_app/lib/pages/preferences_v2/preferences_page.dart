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
import 'package:smooth_app/pages/preferences_v2/roots/connect/connect_root.dart';
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
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';

class PreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    context.watch<UserManagementProvider>();
    final ThemeData theme = Theme.of(context);

    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;

    final Color iconColor = context.lightTheme()
        ? theme.primaryColor
        : Colors.white;

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
              _buildPricesContributionTile(context, appLocalizations),
              _buildHungerGamesTile(context),
              _buildCompleteProductsTile(context, appLocalizations),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_page_customize_app_title,
            tiles: <PreferenceTile>[
              _buildFoodPreferencesTile(appLocalizations, iconColor),
              _buildAppSettingsTile(appLocalizations, iconColor),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_project,
            tiles: <PreferenceTile>[
              _buildContributeProjectTile(appLocalizations, iconColor),
              _buildSupportTile(appLocalizations, iconColor),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_help,
            header: NewNutriscoreHeader(),
            tiles: <PreferenceTile>[
              _buildFaqTile(appLocalizations, iconColor),
              _buildConnectTile(appLocalizations, iconColor),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_about,
            tiles: <PreferenceTile>[
              _buildLegalInformationTile(appLocalizations, iconColor),
              _buildAboutAppTile(appLocalizations, iconColor),
              if (userPreferences.devMode > 0)
                _buildDevModeTile(appLocalizations, iconColor),
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

  // Contribute section
  SquarePreferenceTile _buildPricesContributionTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return SquarePreferenceTile(
      title: appLocalizations.preferences_add_prices,
      illustration: SvgPicture.asset(
        'assets/preferences/prices_contribution.svg',
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<PreferencesRootSearchController>(
                  create: (_) => PreferencesRootSearchController(),
                  child: PricesRoot(
                    title: appLocalizations.preferences_prices_title,
                  ),
                ),
          ),
        );
      },
    );
  }

  SquarePreferenceTile _buildHungerGamesTile(BuildContext context) {
    return SquarePreferenceTile(
      title: 'Hunger Games',
      illustration: SvgPicture.asset(
        'assets/preferences/hunger_games_contribution.svg',
      ),
      onTap: () async {
        AnalyticsHelper.trackEvent(AnalyticsEvent.hungerGameOpened);

        await Navigator.of(context).push<int>(
          MaterialPageRoute<int>(
            builder: (BuildContext context) => const QuestionsPage(),
          ),
        );
      },
    );
  }

  SquarePreferenceTile _buildCompleteProductsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return SquarePreferenceTile(
      title: appLocalizations.preferences_complete_products,
      illustration: SvgPicture.asset(
        'assets/preferences/products_contribution.svg',
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<PreferencesRootSearchController>(
                  create: (_) => PreferencesRootSearchController(),
                  child: ContributionsRoot(
                    title: appLocalizations.preferences_contributions_title,
                  ),
                ),
          ),
        );
      },
    );
  }

  // Customize App section
  NavigationPreferenceTile _buildFoodPreferencesTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return NavigationPreferenceTile(
      leading: icons.HappyToast(color: iconColor),
      title: appLocalizations.myPreferences_food_title,
      subtitleText: appLocalizations.myPreferences_food_subtitle,
      target: const UserPreferencesPage(type: PreferencePageType.FOOD),
    );
  }

  NavigationPreferenceTile _buildAppSettingsTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return NavigationPreferenceTile(
      leading: icons.Personalization.alt(color: iconColor),
      title: appLocalizations.myPreferences_settings_title,
      subtitleText: appLocalizations.myPreferences_settings_subtitle,
      root: AppSettingsRoot(title: appLocalizations.settings_app_app),
    );
  }

  // Project section
  NavigationPreferenceTile _buildContributeProjectTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return NavigationPreferenceTile(
      leading: icons.Contribute(color: iconColor),
      title: appLocalizations.preferences_page_contribute_project_title,
      subtitleText:
          appLocalizations.preferences_page_contribute_project_subtitle,
      root: ContributeRoot(
        title: appLocalizations.preferences_contribute_title,
      ),
    );
  }

  UrlPreferenceTile _buildSupportTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return UrlPreferenceTile(
      leading: icons.Donate(color: iconColor),
      title: appLocalizations.preferences_support_title,
      subtitleText: appLocalizations.preferences_support_subtitle,
      url: appLocalizations.donate_url,
    );
  }

  // Help section
  NavigationPreferenceTile _buildFaqTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return NavigationPreferenceTile(
      leading: icons.Lifebuoy(color: iconColor),
      title: appLocalizations.preferences_faq_subtitle,
      subtitleText: appLocalizations.preferences_page_faq_subtitle,
      root: FaqRoot(title: appLocalizations.preferences_faq_title),
    );
  }

  NavigationPreferenceTile _buildConnectTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return NavigationPreferenceTile(
      leading: icons.Message.edit(color: iconColor),
      title: appLocalizations.preferences_connect_title,
      subtitleText: appLocalizations.preferences_connect_subtitle,
      root: ConnectRoot(title: appLocalizations.preferences_connect_title),
    );
  }

  // About section
  NavigationPreferenceTile _buildLegalInformationTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return NavigationPreferenceTile(
      leading: icons.Info(color: iconColor),
      title: appLocalizations.preferences_legal_information_title,
      subtitleText: appLocalizations.preferences_legal_information_subtitle,
      root: LegalInformationRoot(
        title: appLocalizations.preferences_legal_information_title,
      ),
    );
  }

  NavigationPreferenceTile _buildAboutAppTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return NavigationPreferenceTile(
      leading: icons.Programming(color: iconColor),
      title: appLocalizations.preferences_about_app_title,
      subtitleText: appLocalizations.preferences_about_app_subtitle,
      root: AboutAppRoot(title: appLocalizations.preferences_about_app_title),
    );
  }

  NavigationPreferenceTile _buildDevModeTile(
    AppLocalizations appLocalizations,
    Color iconColor,
  ) {
    return NavigationPreferenceTile(
      leading: icons.Lab(color: iconColor),
      title: appLocalizations.preferences_page_open_food_facts_labs_title,
      subtitleText: appLocalizations.dev_preferences_screen_subtitle,
      root: DevModeRoot(
        title: appLocalizations.preferences_page_open_food_facts_labs_title,
      ),
    );
  }
}
