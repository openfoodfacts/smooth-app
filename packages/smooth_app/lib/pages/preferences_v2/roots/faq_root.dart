import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/user_feedback_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/guide/guide_nutriscore_v2.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';

class FaqRoot extends PreferencesRoot {
  const FaqRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return <PreferenceCard>[
      PreferenceCard(
        title: 'Scores',
        tiles: <PreferenceTile>[
          _createNutriTile(
            title: appLocalizations.nutriscore_generic,
            url: 'https://world.openfoodfacts.org/nutriscore',
            svg: SvgCache.getAssetsCacheForNutriscore(NutriScoreValue.b, false),
          ),
          PreferenceTile(
            leading: _createLeadingIcon(
              SvgCache.getAssetsCacheForNutriscore(NutriScoreValue.b, true),
            ),
            title: appLocalizations.faq_nutriscore_nutriscore,
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const GuideNutriscoreV2(),
              ),
            ),
          ),
          _createNutriTile(
            title: appLocalizations.environmental_score_generic,
            url: 'https://world.openfoodfacts.org/ecoscore',
            svg: 'assets/cache/green-score-b.svg',
          ),
          _createNutriTile(
            title: appLocalizations.nova_group_generic,
            url: 'https://world.openfoodfacts.org/nova',
            svg: 'assets/cache/nova-group-4.svg',
          ),
          _createNutriTile(
            title: appLocalizations.nutrition_facts,
            url: 'https://world.openfoodfacts.org/traffic-lights',
            svg: 'assets/cache/low.svg',
            leadingSvgWidth: 1.5 * DEFAULT_ICON_SIZE,
          ),
        ],
      ),
      PreferenceCard(
        title: 'Miscellaneous',
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: Icons.question_mark,
            title: appLocalizations.faq,
            url: _getFAQUrl(),
          ),
          UrlPreferenceTile(
            icon: Icons.travel_explore,
            title: appLocalizations.discover,
            url: ProductQuery.replaceSubdomain(
              'https://world.openfoodfacts.org/discover',
            ),
          ),
          UrlPreferenceTile(
            icon: Icons.volunteer_activism,
            title: appLocalizations.how_to_contribute,
            url: ProductQuery.replaceSubdomain(
              'https://world.openfoodfacts.org/contribute',
            ),
          ),
          UrlPreferenceTile(
            icon: Icons.add_comment,
            title: appLocalizations.feed_back,
            url: UserFeedbackHelper.getFeedbackFormLink(),
          ),
          UrlPreferenceTile(
            icon: Icons.handshake_outlined,
            title: appLocalizations.faq_title_partners,
            url: ProductQuery.replaceSubdomain(
              'https://world.openfoodfacts.org/partners',
            ),
          ),
          UrlPreferenceTile(
            icon: Icons.remove_red_eye_outlined,
            title: appLocalizations.faq_title_vision,
            url: ProductQuery.replaceSubdomain(
              'https://world.openfoodfacts.org/open-food-facts-vision-mission-values-and-programs',
            ),
          ),
        ],
      ),
    ];
  }

  Widget _createLeadingIcon(String svg, {double? width}) {
    return SizedBox(
      width: 2 * DEFAULT_ICON_SIZE,
      height: 2 * DEFAULT_ICON_SIZE,
      child: Center(
        child: SvgPicture.asset(
          svg,
          width: width ?? 2 * DEFAULT_ICON_SIZE,
          package: AppHelper.APP_PACKAGE,
        ),
      ),
    );
  }

  UrlPreferenceTile _createNutriTile({
    required String title,
    required String url,
    required String svg,
    double? leadingSvgWidth,
  }) {
    return UrlPreferenceTile(
      leading: _createLeadingIcon(svg, width: leadingSvgWidth),
      title: title,
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
