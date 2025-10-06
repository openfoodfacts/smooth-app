import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/logged_in_app_bar.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/logged_out_app_bar.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/hunger_games/question_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/cards/banner/new_nutriscore_header.dart';
import 'package:smooth_app/pages/preferences_v2/cards/footer/preferences_social_networks.dart';
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
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

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
          _buildContributeCard(context, appLocalizations),
          PreferenceCard(
            title: appLocalizations.preferences_page_customize_app_title,
            tiles: <PreferenceTile>[
              _buildFoodPreferencesTile(appLocalizations),
              _buildAppSettingsTile(appLocalizations),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_project,
            tiles: <PreferenceTile>[
              _buildContributeProjectTile(appLocalizations),
              _buildSupportTile(appLocalizations),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_help,
            header: const NutriScoreV2Banner(),
            tiles: <PreferenceTile>[
              _buildFaqTile(appLocalizations),
              _buildConnectTile(appLocalizations),
            ],
          ),
          PreferenceCard(
            title: appLocalizations.preferences_card_about,
            tiles: <PreferenceTile>[
              _buildLegalInformationTile(appLocalizations),
              if (userPreferences.devMode > 0)
                _buildDevModeTile(
                  appLocalizations,
                  context.extension<SmoothColorsThemeExtension>().error,
                ),
              _buildAboutAppTile(appLocalizations),
            ],
          ),
        ],
        externalSearchTiles: const <ExternalSearchPreferenceTile>[
          WikiSearchPreferenceTile(),
          GithubSearchPreferenceTile(),
          ForumSearchPreferenceTile(),
        ],
        footer: (_) => Consumer<PreferencesRootSearchController>(
          builder: (_, PreferencesRootSearchController controller, _) {
            if (controller.query?.isNotEmpty == true) {
              return EMPTY_WIDGET;
            }
            return const SocialNetworksFooter();
          },
        ),
      ),
    );
  }

  // Contribute section
  PreferenceCard _buildContributeCard(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

    return PreferenceCard(
      title: appLocalizations.contribute,
      gridView: true,
      tiles: <PreferenceTile>[
        _buildPricesContributionTile(context, appLocalizations, autoSizeGroup),
        _buildHungerGamesTile(context, autoSizeGroup),
        _buildCompleteProductsTile(context, appLocalizations, autoSizeGroup),
      ],
    );
  }

  SquarePreferenceTile _buildPricesContributionTile(
    BuildContext context,
    AppLocalizations appLocalizations,
    AutoSizeGroup autoSizeGroup,
  ) {
    return SquarePreferenceTile(
      title: appLocalizations.preferences_add_prices,
      illustration: SvgPicture.asset(
        'assets/preferences/prices_contribution.svg',
      ),
      autoSizeGroup: autoSizeGroup,
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

  SquarePreferenceTile _buildHungerGamesTile(
    BuildContext context,
    AutoSizeGroup autoSizeGroup,
  ) {
    return SquarePreferenceTile(
      title: 'Hunger Games',
      illustration: SvgPicture.asset(
        'assets/preferences/hunger_games_contribution.svg',
      ),
      autoSizeGroup: autoSizeGroup,
      onTap: () async {
        AnalyticsHelper.trackEvent(AnalyticsEvent.hungerGameOpened);

        await Navigator.of(context, rootNavigator: true).push<int>(
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
    AutoSizeGroup autoSizeGroup,
  ) {
    return SquarePreferenceTile(
      title: appLocalizations.preferences_complete_products,
      illustration: SvgPicture.asset(
        'assets/preferences/products_contribution.svg',
      ),
      autoSizeGroup: autoSizeGroup,
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
  ) {
    return NavigationPreferenceTile(
      leading: const icons.HappyToast(),
      title: appLocalizations.myPreferences_food_title,
      subtitleText: appLocalizations.myPreferences_food_subtitle,
      target: const UserPreferencesPage(type: PreferencePageType.FOOD),
    );
  }

  NavigationPreferenceTile _buildAppSettingsTile(
    AppLocalizations appLocalizations,
  ) {
    return NavigationPreferenceTile(
      leading: const icons.Personalization.alt(size: 20.0),
      title: appLocalizations.myPreferences_settings_title,
      subtitleText: appLocalizations.myPreferences_settings_subtitle,
      root: AppSettingsRoot(title: appLocalizations.settings_app_app),
    );
  }

  // Project section
  NavigationPreferenceTile _buildContributeProjectTile(
    AppLocalizations appLocalizations,
  ) {
    return NavigationPreferenceTile(
      leading: const icons.Contribute(),
      title: appLocalizations.preferences_page_contribute_project_title,
      subtitleText:
          appLocalizations.preferences_page_contribute_project_subtitle,
      root: ContributeRoot(
        title: appLocalizations.preferences_contribute_title,
      ),
    );
  }

  UrlPreferenceTile _buildSupportTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      leading: const icons.Donate(),
      title: appLocalizations.preferences_support_title,
      subtitleText: appLocalizations.preferences_support_subtitle,
      url: appLocalizations.donate_url,
    );
  }

  // Help section
  NavigationPreferenceTile _buildFaqTile(AppLocalizations appLocalizations) {
    return NavigationPreferenceTile(
      leading: const icons.Lifebuoy(),
      title: appLocalizations.preferences_faq_subtitle,
      subtitleText: appLocalizations.preferences_page_faq_subtitle,
      root: FaqRoot(title: appLocalizations.preferences_faq_title),
    );
  }

  NavigationPreferenceTile _buildConnectTile(
    AppLocalizations appLocalizations,
  ) {
    return NavigationPreferenceTile(
      leading: const icons.Message(),
      title: appLocalizations.preferences_connect_title,
      subtitleText: appLocalizations.preferences_connect_subtitle,
      root: ConnectRoot(title: appLocalizations.preferences_connect_title),
    );
  }

  // About section
  NavigationPreferenceTile _buildLegalInformationTile(
    AppLocalizations appLocalizations,
  ) {
    return NavigationPreferenceTile(
      leading: const icons.Law(),
      title: appLocalizations.preferences_legal_information_title,
      subtitleText: appLocalizations.preferences_legal_information_subtitle,
      root: LegalInformationRoot(
        title: appLocalizations.preferences_legal_information_title,
      ),
    );
  }

  NavigationPreferenceTile _buildAboutAppTile(
    AppLocalizations appLocalizations,
  ) {
    return NavigationPreferenceTile(
      leading: const icons.Info(),
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
      icon: const icons.DangerousZone(),
      title: appLocalizations.preferences_page_open_food_facts_labs_title,
      subtitleText: appLocalizations.dev_preferences_screen_subtitle,
      root: DevModeRoot(
        title: appLocalizations.preferences_page_open_food_facts_labs_title,
      ),
    );
  }
}
