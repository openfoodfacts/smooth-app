import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_page.dart';
import 'package:smooth_app/pages/food_preferences/preferences_page_projects.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

class GuideOpenPetFoodFacts extends StatelessWidget {
  const GuideOpenPetFoodFacts({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesPage.smallHeader(
      pageName: 'OpenPetFoodFacts',
      header: const _OpenPetFoodFactsHeader(),
      body: const <Widget>[
        _OpenPetFoodFactsSection1(),
        _OpenPetFoodFactsSection2(),
        _OpenPetFoodFactsSection3(),
        _OpenPetFoodFactsSection4(),
      ],
      footer: SliverToBoxAdapter(
        child: GuidesFooter(
          shareUrl: appLocalizations.guide_open_pet_food_facts_share_link,
        ),
      ),
    );
  }
}

class _OpenPetFoodFactsHeader extends StatelessWidget {
  const _OpenPetFoodFactsHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesHeader(
      title: appLocalizations.guide_open_pet_food_facts_title,
      illustration: const _OpenPetFoodFactsHeaderIllustration(),
    );
  }
}

class _OpenPetFoodFactsHeaderIllustration extends StatelessWidget {
  const _OpenPetFoodFactsHeaderIllustration();

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
                'assets/guides/open_pet_food_facts/open_pet_food_facts_logo.svg.vec',
              ),
              width: 160.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenPetFoodFactsSection1 extends StatelessWidget {
  const _OpenPetFoodFactsSection1();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations
          .guide_open_pet_food_facts_what_is_open_pet_food_facts_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations
              .guide_open_pet_food_facts_what_is_open_pet_food_facts_paragraph1,
        ),
        GuidesText(
          text: appLocalizations
              .guide_open_pet_food_facts_what_is_open_pet_food_facts_paragraph2,
        ),
        const Padding(
          padding: EdgeInsetsDirectional.only(top: LARGE_SPACE),
          child: SvgPicture(
            AssetBytesLoader(
              'assets/guides/open_pet_food_facts/pet_food_kibble_bag.svg.vec',
            ),
            width: 70.0,
          ),
        ),
      ],
    );
  }
}

class _OpenPetFoodFactsSection2 extends StatelessWidget {
  const _OpenPetFoodFactsSection2();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_pet_food_facts_features_title,
      content: <Widget>[
        GuidesTitleWithText(
          icon: const icons.StopSign(),
          title: appLocalizations.guide_open_pet_food_facts_features_arg1_title,
          text: appLocalizations
              .guide_open_pet_food_facts_features_arg1_paragraph1,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: VERY_LARGE_SPACE,
          ),
          child: ClipRRect(
            borderRadius: ROUNDED_BORDER_RADIUS,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: ROUNDED_BORDER_RADIUS,
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: PreferenceTile(
                leading: PreferencesPageProjects.pets.getLeadingIcon(
                  context.lightTheme(),
                ),
                title: PreferencesPageProjects.pets.getTitle(appLocalizations),
                subtitleText: PreferencesPageProjects.pets.getSubtitle(
                  appLocalizations,
                ),
                borderRadius: ROUNDED_BORDER_RADIUS,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const FoodPreferencesPage(
                            project: PreferencesPageProjects.pets,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenPetFoodFactsSection3 extends StatelessWidget {
  const _OpenPetFoodFactsSection3();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String assetSuffix = context.lightTheme() ? 'light' : 'dark';

    return GuidesParagraph(
      title: appLocalizations.guide_open_pet_food_facts_tips_title,
      content: <Widget>[
        GuidesTitleContainer(
          title: appLocalizations.guide_open_pet_food_facts_tips_arg2_title,
          icon: const icons.Thumb.up(size: 20.0, color: Colors.white),
          child: GuidesGrid(
            columns: 2,
            verticalSpacing: SMALL_SPACE,
            horizontalSpacing: MEDIUM_SPACE,
            maxLines: 2,
            itemWidthPercent: 0.22,
            items: <GuidesGridItem>[
              GuidesGridItem(
                label:
                    appLocalizations.guide_open_pet_food_facts_tips_arg2_text1,
                asset:
                    'assets/guides/shared/photo_lightning_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label:
                    appLocalizations.guide_open_pet_food_facts_tips_arg2_text2,
                asset: 'assets/guides/shared/photo_sharp_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label:
                    appLocalizations.guide_open_pet_food_facts_tips_arg2_text3,
                asset:
                    'assets/guides/shared/photo_capture_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label:
                    appLocalizations.guide_open_pet_food_facts_tips_arg2_text4,
                asset:
                    'assets/guides/shared/photo_surface_$assetSuffix.svg.vec',
              ),
            ],
          ),
        ),
        GuidesTitleContainer(
          title: appLocalizations.guide_open_pet_food_facts_tips_arg1_title,
          icon: const icons.Thumb.down(size: 20.0, color: Colors.white),
          child: GuidesGrid(
            columns: 2,
            verticalSpacing: SMALL_SPACE,
            horizontalSpacing: MEDIUM_SPACE,
            maxLines: 2,
            itemWidthPercent: 0.22,
            items: <GuidesGridItem>[
              GuidesGridItem(
                label:
                    appLocalizations.guide_open_pet_food_facts_tips_arg1_text1,
                asset:
                    'assets/guides/shared/photo_shadows_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label:
                    appLocalizations.guide_open_pet_food_facts_tips_arg1_text2,
                asset: 'assets/guides/shared/photo_blurry_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label:
                    appLocalizations.guide_open_pet_food_facts_tips_arg1_text3,
                asset: 'assets/guides/shared/photo_crop_$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label:
                    appLocalizations.guide_open_pet_food_facts_tips_arg1_text4,
                asset: 'assets/guides/shared/photo_busy_$assetSuffix.svg.vec',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpenPetFoodFactsSection4 extends StatelessWidget {
  const _OpenPetFoodFactsSection4();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_pet_food_facts_scores_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations.guide_open_pet_food_facts_scores_paragraph1,
        ),
      ],
    );
  }
}
