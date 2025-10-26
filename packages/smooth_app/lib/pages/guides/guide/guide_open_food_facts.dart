import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/guide/guide_green_score.dart';
import 'package:smooth_app/pages/guides/guide/guide_nova.dart';
import 'package:smooth_app/pages/guides/guide/guide_nutriscore_v2.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

class GuideOpenFoodFacts extends StatelessWidget {
  const GuideOpenFoodFacts({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesPage.smallHeader(
      pageName: 'OpenFoodFacts',
      header: const _OpenFoodFactsHeader(),
      body: const <Widget>[
        _OpenFoodFactsSection1(),
        _OpenFoodFactsSection2(),
        _OpenFoodFactsSection3(),
      ],
      footer: SliverToBoxAdapter(
        child: GuidesFooter(
          shareUrl: appLocalizations.guide_open_food_facts_share_link,
        ),
      ),
    );
  }
}

class _OpenFoodFactsHeader extends StatelessWidget {
  const _OpenFoodFactsHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesHeader(
      title: appLocalizations.guide_open_food_facts_title,
      illustration: const _OpenFoodFactsHeaderIllustration(),
    );
  }
}

class _OpenFoodFactsHeaderIllustration extends StatelessWidget {
  const _OpenFoodFactsHeaderIllustration();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 32,
            child: SvgPicture(
              AssetBytesLoader(
                'assets/guides/open_food_facts/open_food_facts_logo.svg.vec',
              ),
              width: 110.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenFoodFactsSection1 extends StatelessWidget {
  const _OpenFoodFactsSection1();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title:
          appLocalizations.guide_open_food_facts_what_is_open_food_facts_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations
              .guide_open_food_facts_what_is_open_food_facts_paragraph1,
        ),
        GuidesText(
          text: appLocalizations
              .guide_open_food_facts_what_is_open_food_facts_paragraph2,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            top: BALANCED_SPACE,
            bottom: SMALL_SPACE,
          ),
          child: Transform.rotate(
            angle: 0.39 * (360.0 / (math.pi)),
            child: const SvgPicture(
              AssetBytesLoader(
                'assets/guides/open_food_facts/chocolate_bar_eaten.svg.vec',
              ),
              width: 80.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenFoodFactsSection3 extends StatelessWidget {
  const _OpenFoodFactsSection3();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String assetSuffix = context.lightTheme() ? 'light' : 'dark';

    return GuidesParagraph(
      title: appLocalizations.guide_open_food_facts_tips_title,
      content: <Widget>[
        GuidesTitleContainer(
          title: appLocalizations.guide_open_food_facts_tips_arg2_title,
          icon: const icons.Thumb.up(size: 20.0, color: Colors.white),
          child: GuidesGrid(
            columns: 2,
            verticalSpacing: SMALL_SPACE,
            horizontalSpacing: MEDIUM_SPACE,
            maxLines: 2,
            itemWidthPercent: 0.22,
            items: <GuidesGridItem>[
              GuidesGridItem(
                label: appLocalizations.guide_open_food_facts_tips_arg2_text1,
                asset:
                    'assets/guides/shared/photo_lightning_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_open_food_facts_tips_arg2_text2,
                asset: 'assets/guides/shared/photo_sharp_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_open_food_facts_tips_arg2_text3,
                asset:
                    'assets/guides/shared/photo_capture_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_open_food_facts_tips_arg2_text4,
                asset:
                    'assets/guides/shared/photo_surface_$assetSuffix.svg.vec',
              ),
            ],
          ),
        ),
        GuidesTitleContainer(
          title: appLocalizations.guide_open_food_facts_tips_arg1_title,
          icon: const icons.Thumb.down(size: 20.0, color: Colors.white),
          child: GuidesGrid(
            columns: 2,
            verticalSpacing: SMALL_SPACE,
            horizontalSpacing: MEDIUM_SPACE,
            maxLines: 2,
            itemWidthPercent: 0.22,
            items: <GuidesGridItem>[
              GuidesGridItem(
                label: appLocalizations.guide_open_food_facts_tips_arg1_text1,
                asset:
                    'assets/guides/shared/photo_shadows_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_open_food_facts_tips_arg1_text2,
                asset: 'assets/guides/shared/photo_blurry_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_open_food_facts_tips_arg1_text3,
                asset: 'assets/guides/shared/photo_crop_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_open_food_facts_tips_arg1_text4,
                asset: 'assets/guides/shared/photo_busy_$assetSuffix.svg.vec',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpenFoodFactsSection2 extends StatelessWidget {
  const _OpenFoodFactsSection2();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_food_facts_scores_title,
      content: <Widget>[
        GuidesTitleContainer(
          title: appLocalizations.guide_open_food_facts_scores_arg1_title,
          icon: const icons.Ingredients(),
          child: GuidesImage(
            imagePath: SvgCache.getAssetsCacheForNutriscore(
              NutriScoreValue.a,
              true,
            ),
            caption: appLocalizations.guide_learn_more_subtitle,
            desiredWidthPercent: 0.30,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const GuideNutriscoreV2(),
                ),
              );
            },
          ),
        ),
        GuidesTitleContainer(
          title: appLocalizations.guide_open_food_facts_scores_arg2_title,
          icon: const icons.Factory(),
          child: GuidesImage(
            imagePath: 'assets/guides/open_food_facts/score_nova.svg.vec',
            caption: appLocalizations.guide_learn_more_subtitle,
            desiredWidthPercent: 0.1,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const GuideNOVA(),
                ),
              );
            },
          ),
        ),
        GuidesTitleContainer(
          title: appLocalizations.guide_open_food_facts_scores_arg3_title,
          icon: const icons.World.location(),
          child: GuidesImage(
            imagePath: 'assets/cache/green-score-a-plus.svg',
            caption: appLocalizations.guide_learn_more_subtitle,
            spacing: SMALL_SPACE,
            desiredWidthPercent: 0.30,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const GuideGreenScore(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
