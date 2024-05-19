import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/pages/guides/helpers/guides_translations.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart';

class GuideNutriscoreV2 extends StatelessWidget {
  const GuideNutriscoreV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: GuidesTranslations.init(
          Locale(ProductQuery.getLanguage().offTag),
        ),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const _GuideNutriscoreV2Content();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _GuideNutriscoreV2Content extends StatelessWidget {
  const _GuideNutriscoreV2Content({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _NutriscoreHeader(),
          _NutriScoreSection1(),
          _NutriScoreSection2(),
          _NutriScoreSection3(),
          _NutriScoreSection4(),
          _NutriScoreSection5(),
          SliverToBoxAdapter(
            child: GuidesFooter(),
          )
        ],
      ),
    );
  }
}

class _NutriscoreHeader extends StatelessWidget {
  const _NutriscoreHeader();

  @override
  Widget build(BuildContext context) {
    return GuidesHeader(
      title: 'guide_nutriscore_v2_title'.translation,
      illustration: const _NutriScoreHeaderIllustration(),
    );
  }
}

class _NutriScoreHeaderIllustration extends StatelessWidget {
  const _NutriScoreHeaderIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 32,
          child: SvgPicture.asset('assets/cache/nutriscore-a.svg'),
        ),
        const Expanded(
          flex: 28,
          child: Arrow.down(
            color: Colors.white,
          ),
        ),
        Expanded(
          flex: 40,
          child: SvgPicture.asset(
              'assets/cache/nutriscore-a-new-${'guide_nutriscore_v2_file_language'.translation}.svg'),
        ),
      ],
    );
  }
}

class _NutriScoreSection1 extends StatelessWidget {
  const _NutriScoreSection1();

  @override
  Widget build(BuildContext context) {
    return GuidesParagraph(
      title: 'guide_nutriscore_v2_what_is_nutriscore_title'.translation,
      content: <Widget>[
        GuidesText(
          text: 'guide_nutriscore_v2_what_is_nutriscore_paragraph1'.translation,
        ),
        GuidesText(
          text: 'guide_nutriscore_v2_what_is_nutriscore_paragraph2'.translation,
        ),
        GuidesImage(
          imagePath: 'assets/cache/nutriscore-a.svg',
          caption: 'guide_nutriscore_v2_nutriscore_a_caption'.translation,
          desiredWidthPercent: 0.30,
        ),
      ],
    );
  }
}

class _NutriScoreSection2 extends StatelessWidget {
  const _NutriScoreSection2();

  @override
  Widget build(BuildContext context) {
    return GuidesParagraph(
      title: 'guide_nutriscore_v2_why_v2_title'.translation,
      content: <Widget>[
        GuidesText(
          text: 'guide_nutriscore_v2_why_v2_intro'.translation,
        ),
        GuidesTitleWithText(
          title: 'guide_nutriscore_v2_why_v2_arg1_title'.translation,
          icon: const Milk(),
          text: 'guide_nutriscore_v2_why_v2_arg1_text'.translation,
        ),
        GuidesTitleWithText(
          title: 'guide_nutriscore_v2_why_v2_arg2_title'.translation,
          icon: const Soda.unhappy(),
          text: 'guide_nutriscore_v2_why_v2_arg2_text'.translation,
        ),
        GuidesTitleWithText(
          title: 'guide_nutriscore_v2_why_v2_arg3_title'.translation,
          icon: const Salt(),
          text: 'guide_nutriscore_v2_why_v2_arg3_text'.translation,
        ),
        GuidesTitleWithText(
          title: 'guide_nutriscore_v2_why_v2_arg4_title'.translation,
          icon: const Fish(),
          text: 'guide_nutriscore_v2_why_v2_arg4_text'.translation,
        ),
        GuidesTitleWithText(
          title: 'guide_nutriscore_v2_why_v2_arg5_title'.translation,
          icon: const Chicken(),
          text: 'guide_nutriscore_v2_why_v2_arg5_text'.translation,
        ),
      ],
    );
  }
}

class _NutriScoreSection3 extends StatelessWidget {
  const _NutriScoreSection3();

  @override
  Widget build(BuildContext context) {
    return GuidesParagraph(
      title: 'guide_nutriscore_v2_new_logo_title'.translation,
      content: <Widget>[
        GuidesText(
          text: 'guide_nutriscore_v2_new_logo_text'.translation,
        ),
        GuidesImage(
          imagePath:
              'assets/cache/nutriscore-a-new-${'guide_nutriscore_v2_file_language'.translation}.svg',
          caption: 'guide_nutriscore_v2_new_logo_image_caption'.translation,
          desiredWidthPercent: 0.30,
        ),
      ],
    );
  }
}

class _NutriScoreSection4 extends StatelessWidget {
  const _NutriScoreSection4();

  @override
  Widget build(BuildContext context) {
    return GuidesParagraph(
      title: 'guide_nutriscore_v2_where_title'.translation,
      content: <Widget>[
        GuidesText(text: 'guide_nutriscore_v2_where_paragraph1'.translation),
        GuidesText(text: 'guide_nutriscore_v2_where_paragraph2'.translation),
        GuidesIllustratedText(
          text: 'guide_nutriscore_v2_where_paragraph3'.translation,
          imagePath: 'assets/app/release_icon_light_transparent_no_border.svg',
          desiredWidthPercent: 0.15,
        )
      ],
    );
  }
}

class _NutriScoreSection5 extends StatelessWidget {
  const _NutriScoreSection5();

  @override
  Widget build(BuildContext context) {
    return GuidesParagraph(
      title: 'guide_nutriscore_v2_unchanged_title'.translation,
      content: <Widget>[
        GuidesText(
          text: 'guide_nutriscore_v2_unchanged_paragraph1'.translation,
        ),
        GuidesText(
          text: 'guide_nutriscore_v2_unchanged_paragraph2'.translation,
        ),
      ],
    );
  }
}
