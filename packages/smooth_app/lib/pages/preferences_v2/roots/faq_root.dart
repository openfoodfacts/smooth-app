import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/guide/guide_green_score.dart';
import 'package:smooth_app/pages/guides/guide/guide_nova.dart';
import 'package:smooth_app/pages/guides/guide/guide_nutriscore_v2.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:vector_graphics/vector_graphics.dart';

class FaqRoot extends PreferencesRoot {
  const FaqRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_faq_scores_methodologies_title,
        tiles: <PreferenceTile>[
          _buildNutriscoreTile(appLocalizations),
          _buildNutriscoreV2Tile(context, appLocalizations),
          _buildGreenScoreTile(context, appLocalizations),
          _buildNovaTile(context, appLocalizations),
          _buildTrafficLightsTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_faq_discover_project_title,
        tiles: <PreferenceTile>[
          _buildDiscoverOffTile(appLocalizations),
          _buildHowToContributeTile(appLocalizations),
          _buildFaqTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_faq_off_ngo_title,
        tiles: <PreferenceTile>[
          _buildPartnersTile(appLocalizations),
          _buildVisionTile(appLocalizations),
        ],
      ),
    ];
  }

  // Scores and Methodologies section
  PreferenceTile _buildNutriscoreTile(AppLocalizations appLocalizations) {
    return _createScoreTile(
      title: appLocalizations.nutriscore_generic,
      subtitleText: appLocalizations.preferences_faq_nutriscore_subtitle,
      url: 'https://world.openfoodfacts.org/nutriscore',
      svg: SvgCache.getAssetsCacheForNutriscore(NutriScoreValue.b, false),
      leadingSvgWidth: 30.0,
    );
  }

  PreferenceTile _buildNutriscoreV2Tile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: _createLeadingIcon(
        SvgCache.getAssetsCacheForNutriscore(NutriScoreValue.b, true),
      ),
      title: appLocalizations.faq_nutriscore_nutriscore,
      subtitleText: appLocalizations.preferences_faq_nutriscore_v2_subtitle,
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const GuideNutriscoreV2(),
        ),
      ),
    );
  }

  PreferenceTile _buildGreenScoreTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: _createLeadingIcon(
        'assets/guides/greenscore/greenscore_a.svg.vec',
      ),
      title: appLocalizations.environmental_score_generic_new,
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const GuideGreenScore(),
        ),
      ),
    );
  }

  PreferenceTile _buildNovaTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: _createLeadingIcon('assets/cache/nova-group-4.svg'),
      title: appLocalizations.nova_group_generic_new,
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const GuideNOVA(),
        ),
      ),
    );
  }

  PreferenceTile _buildTrafficLightsTile(AppLocalizations appLocalizations) {
    return _createScoreTile(
      title: appLocalizations.nutrition_facts,
      subtitleText: 'Discover the UK FSA methodology',
      url: 'https://world.openfoodfacts.org/traffic-lights',
      svg: 'assets/cache/low.svg',
    );
  }

  // Discover Project section
  PreferenceTile _buildDiscoverOffTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Discover(),
      title: appLocalizations.preferences_faq_discover_off_title,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/discover',
      ),
    );
  }

  PreferenceTile _buildHowToContributeTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Student(),
      title: appLocalizations.how_to_contribute,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/contribute',
      ),
    );
  }

  PreferenceTile _buildFaqTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      leading: const icons.Faq(),
      title: appLocalizations.preferences_faq_faq_title,
      url: _getFAQUrl(),
    );
  }

  // OFF NGO section
  PreferenceTile _buildPartnersTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Partners(),
      title: appLocalizations.faq_title_partners,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/partners',
      ),
    );
  }

  PreferenceTile _buildVisionTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Vision(),
      title: appLocalizations.faq_title_vision,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/open-food-facts-vision-mission-values-and-programs',
      ),
    );
  }

  Widget _createLeadingIcon(String svg) {
    if (svg.endsWith('vec')) {
      return SvgPicture(AssetBytesLoader(svg), width: 48.0);
    } else {
      return SvgPicture.asset(svg, width: 48.0);
    }
  }

  PreferenceTile _createScoreTile({
    required String title,
    required String url,
    required String svg,
    String? subtitleText,
    double? leadingSvgWidth,
  }) {
    return UrlPreferenceTile(
      leading: _createLeadingIcon(svg),
      leadingSize: leadingSvgWidth,
      title: title,
      subtitleText: subtitleText,
      url: ProductQuery.replaceSubdomain(url),
    );
  }

  String _getFAQUrl() {
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();

    // TODO(teolemon): regularly check for additional translations
    return switch (language) {
      OpenFoodFactsLanguage.FRENCH =>
        'https://support.openfoodfacts.org/help/fr-fr',
      OpenFoodFactsLanguage.ITALIAN =>
        'https://support.openfoodfacts.org/help/it-it',
      OpenFoodFactsLanguage.GERMAN =>
        'https://support.openfoodfacts.org/help/de-de',
      OpenFoodFactsLanguage.SPANISH =>
        'https://support.openfoodfacts.org/help/es-es',
      _ => 'https://support.openfoodfacts.org/help',
    };
  }
}
