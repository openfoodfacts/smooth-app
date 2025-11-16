import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/helpers/contribute_ui_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ContributeRoot extends PreferencesRoot {
  const ContributeRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OpenFoodFactsCountry country = ProductQuery.getCountry();

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_contribute_active_volunteer_title,
        tiles: <PreferenceTile>[
          _buildSkillPoolTile(appLocalizations),
          _buildHowToContributeTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_mobile_dev_title,
        tiles: <PreferenceTile>[
          _buildSoftwareDevelopmentTile(context, appLocalizations),
          if (GlobalVars.appStore.getEnrollInBetaURL() != null)
            _buildEnrollAlphaTile(context, appLocalizations),
          _buildContributorsTile(context, appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_local_community_title,
        tiles: <PreferenceTile>[
          _buildTranslateTile(context, appLocalizations),
          _buildShareTile(appLocalizations),
          if (country.wikiUrl != null)
            _buildCountryImproveTile(appLocalizations, country),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_data_quality_title,
        tiles: <PreferenceTile>[_buildDataQualityTile(appLocalizations)],
      ),
    ];
  }

  // Active Volunteer section
  UrlPreferenceTile _buildSkillPoolTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      leading: const icons.Student(),
      title: appLocalizations.contribute_join_skill_pool,
      subtitleText: appLocalizations.preferences_contribute_skill_pool_subtitle,
      url:
          'https://connect.openfoodfacts.org/join-the-contributor-skill-pool-open-food-facts',
    );
  }

  UrlPreferenceTile _buildHowToContributeTile(
    AppLocalizations appLocalizations,
  ) {
    return UrlPreferenceTile(
      leading: const icons.Book(),
      title: appLocalizations.how_to_contribute,
      subtitleText: appLocalizations.preferences_contribute_how_to_subtitle,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/contribute',
      ),
    );
  }

  // Mobile Development section
  PreferenceTile _buildSoftwareDevelopmentTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: const icons.Construction(),
      title: appLocalizations.contribute_sw_development,
      subtitleText: appLocalizations.preferences_contribute_sw_dev_subtitle,
      onTap: () async => ContributeUIHelper.showDevelopBottomSheet(context),
    );
  }

  PreferenceTile _buildEnrollAlphaTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: const icons.Lab.alt(),
      title: appLocalizations.preferences_contribute_enroll_alpha,
      subtitleText: appLocalizations.preferences_contribute_alpha_subtitle,
      onTap: () async =>
          ContributeUIHelper.showEnrollInInternalBottomSheet(context),
    );
  }

  PreferenceTile _buildContributorsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: const icons.CrossWalk(),
      title: appLocalizations.contributors_label,
      subtitleText: appLocalizations.contributors_description,
      onTap: () async =>
          ContributeUIHelper.showContributorsBottomSheet(context),
    );
  }

  // Local Community section
  PreferenceTile _buildTranslateTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: const icons.Language(),
      title: appLocalizations.preferences_contribute_translate_header,
      subtitleText: appLocalizations.preferences_contribute_translate_subtitle,
      onTap: () async => ContributeUIHelper.showTranslateBottomSheet(context),
    );
  }

  PreferenceTile _buildShareTile(AppLocalizations appLocalizations) {
    return PreferenceTile(
      leading: const icons.Coffee.love(),
      title: appLocalizations.contribute_share_header,
      subtitleText: appLocalizations.preferences_contribute_share_subtitle,
      onTap: () async => _share(appLocalizations.contribute_share_content),
    );
  }

  UrlPreferenceTile _buildCountryImproveTile(
    AppLocalizations appLocalizations,
    OpenFoodFactsCountry country,
  ) {
    return UrlPreferenceTile(
      leading: const icons.World.help(),
      title: appLocalizations.help_improve_country,
      subtitleText: appLocalizations.preferences_contribute_country_subtitle,
      url: country.wikiUrl!,
    );
  }

  // Data Quality section
  UrlPreferenceTile _buildDataQualityTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      leading: const icons.Certificate(),
      title: appLocalizations.preferences_contribute_data_quality_team_title,
      subtitleText:
          appLocalizations.preferences_contribute_data_quality_team_subtitle,
      url: 'https://wiki.openfoodfacts.org/Data_quality',
    );
  }

  Future<void> _share(String content) async =>
      SharePlus.instance.share(ShareParams(text: content));
}
