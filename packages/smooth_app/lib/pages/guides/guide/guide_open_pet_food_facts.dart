import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_button_with_arrow.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class GuideOpenPetFoodFacts extends StatelessWidget {
  const GuideOpenPetFoodFacts({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesPage(
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
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 32,
            child: SvgPicture.asset(
              'assets/guides/open_pet_food_facts/open_pet_food_facts_logo.svg',
              width: 120.0,
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
        Padding(
          padding: const EdgeInsetsDirectional.only(top: LARGE_SPACE),
          child: SvgPicture.asset(
            'assets/guides/open_pet_food_facts/pet_food_kibble_bag.svg',
            width: 80.0,
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
          icon: const icons.Ingredients.alt(),
          title: appLocalizations.guide_open_pet_food_facts_features_arg1_title,
          text: appLocalizations
              .guide_open_pet_food_facts_features_arg1_paragraph1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SmoothButtonWithArrow(
              text: appLocalizations.guide_coming_soon_button_title,
              backgroundColor: theme.disabledColor,
              arrowColor: theme.disabledColor,
            ),
          ],
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

    return GuidesParagraph(
      title: appLocalizations.guide_open_pet_food_facts_tips_title,
      content: <Widget>[
        GuidesTitleWithBulletPoints(
          title: appLocalizations.guide_open_pet_food_facts_tips_arg1_title,
          icon: const Icon(Icons.thumb_down, size: 20.0, color: Colors.white),
          bulletPoints: <String>[
            appLocalizations.guide_open_pet_food_facts_tips_arg1_text1,
            appLocalizations.guide_open_pet_food_facts_tips_arg1_text2,
            appLocalizations.guide_open_pet_food_facts_tips_arg1_text3,
            appLocalizations.guide_open_pet_food_facts_tips_arg1_text4,
          ],
          type: BulletPointType.arrow,
        ),
        GuidesTitleWithBulletPoints(
          title: appLocalizations.guide_open_pet_food_facts_tips_arg2_title,
          icon: const Icon(Icons.thumb_up, size: 20.0, color: Colors.white),
          bulletPoints: <String>[
            appLocalizations.guide_open_pet_food_facts_tips_arg2_text1,
            appLocalizations.guide_open_pet_food_facts_tips_arg2_text2,
            appLocalizations.guide_open_pet_food_facts_tips_arg2_text3,
            appLocalizations.guide_open_pet_food_facts_tips_arg2_text4,
          ],
          type: BulletPointType.arrow,
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
