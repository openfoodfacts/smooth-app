import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

class GuideGreenScore extends StatelessWidget {
  const GuideGreenScore({super.key});

  @override
  Widget build(BuildContext context) {
    return GuidesPage(
      pageName: 'GreenScore',
      header: const _GreenScoreHeader(),
      body: const <Widget>[
        _GreenScoreSection1(),
        _GreenScoreSection2(),
        _GreenScoreSection3(),
        _GreenScoreSection4(),
        _GreenScoreSection5(),
      ],
      footer: SliverToBoxAdapter(
        child: GuidesFooter(
          shareUrl: ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/green-score',
          ),
        ),
      ),
    );
  }
}

class _GreenScoreHeader extends StatelessWidget {
  const _GreenScoreHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesHeader(
      title: appLocalizations.guide_greenscore_title,
      illustration: const _GreenScoreHeaderIllustration(),
    );
  }
}

class _GreenScoreHeaderIllustration extends StatelessWidget {
  const _GreenScoreHeaderIllustration();

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
              'assets/cache/green-score-a-plus.svg',
              width: 120.0,
            ),
          ),
          const Expanded(
            flex: 28,
            child: icons.Arrow.down(color: Colors.white),
          ),
          Expanded(
            flex: 40,
            child: SvgPicture.asset(
              'assets/cache/green-score-f.svg',
              width: 120.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenScoreSection1 extends StatelessWidget {
  const _GreenScoreSection1();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_greenscore_what_is_greenscore_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations.guide_greenscore_what_is_greenscore_paragraph1,
        ),
        GuidesText(
          text: appLocalizations.guide_greenscore_what_is_greenscore_paragraph2,
        ),
        const _GreenScoreLogos(),
      ],
    );
  }
}

class _GreenScoreSection2 extends StatelessWidget {
  const _GreenScoreSection2();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_greenscore_better_product_title,
      content: <Widget>[
        GuidesTitleWithText(
          icon: const icons.Monkey.wondering(),
          title: appLocalizations.guide_greenscore_better_product_arg1_title,
          text: appLocalizations.guide_greenscore_better_product_arg1_text,
        ),
        GuidesTitleWithText(
          icon: const icons.Strength(),
          title: appLocalizations.guide_greenscore_better_product_arg2_title,
          text: appLocalizations.guide_greenscore_better_product_arg2_text,
        ),
        GuidesTitleWithText(
          icon: const icons.Transparency(),
          title: appLocalizations.guide_greenscore_better_product_arg3_title,
          text: appLocalizations.guide_greenscore_better_product_arg3_text,
        ),
        GuidesTitleWithText(
          icon: const icons.Document.sparkles(),
          title: appLocalizations.guide_greenscore_better_product_arg4_title,
          text: appLocalizations.guide_greenscore_better_product_arg4_text,
        ),
      ],
    );
  }
}

class _GreenScoreLogos extends StatelessWidget {
  const _GreenScoreLogos();

  static const List<String> assets = <String>[
    'assets/guides/greenscore/greenscore_a_plus.svg.vec',
    'assets/guides/greenscore/greenscore_a.svg.vec',
    'assets/guides/greenscore/greenscore_b.svg.vec',
    'assets/guides/greenscore/greenscore_c.svg.vec',
    'assets/guides/greenscore/greenscore_d.svg.vec',
    'assets/guides/greenscore/greenscore_e.svg.vec',
    'assets/guides/greenscore/greenscore_f.svg.vec',
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesCaptionContainer(
      caption: appLocalizations.guide_greenscore_logos_caption,
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          final double maxWidth = constraints.maxWidth * 0.8;

          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: assets
                      .map(
                        (String path) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture(
                              AssetBytesLoader(path),
                              width: maxWidth / (assets.length + 1),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
                SvgPicture(
                  AssetBytesLoader(
                    context.lightTheme()
                        ? 'assets/guides/greenscore/logos_arrow.svg.vec'
                        : 'assets/guides/greenscore/logos_arrow_dark.svg.vec',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GreenScoreSection3 extends StatelessWidget {
  const _GreenScoreSection3();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String assetSuffix = context.lightTheme() ? '' : '_dark';

    return GuidesParagraph(
      title: appLocalizations.guide_greenscore_lca_title,
      content: <Widget>[
        GuidesTitleWithText(
          title: appLocalizations.guide_greenscore_lca_arg1_title,
          icon: const icons.Lab.alt(),
          text: appLocalizations.guide_greenscore_lca_arg1_text1,
        ),
        GuidesText(text: appLocalizations.guide_greenscore_lca_arg1_text2),
        GuidesText(text: appLocalizations.guide_greenscore_lca_arg1_text3),
        GuidesTitleContainer(
          title: appLocalizations.guide_greenscore_lca_arg2_title,
          icon: const icons.Gears(),
          child: GuidesGrid(
            columns: 3,
            verticalSpacing: SMALL_SPACE,
            horizontalSpacing: MEDIUM_SPACE,
            items: <GuidesGridItem>[
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_agriculture,
                asset:
                    'assets/guides/greenscore/step_agriculture$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_processing,
                asset:
                    'assets/guides/greenscore/step_processing$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_packaging,
                asset:
                    'assets/guides/greenscore/step_packaging$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label:
                    appLocalizations.guide_greenscore_lca_arg2_transportation,
                asset:
                    'assets/guides/greenscore/step_transportation$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_distribution,
                asset:
                    'assets/guides/greenscore/step_distribution$assetSuffix.svg.vec',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_consumption,
                asset:
                    'assets/guides/greenscore/step_consumption$assetSuffix.svg.vec',
              ),
            ],
          ),
        ),
        GuidesTitleWithBulletPoints(
          title: appLocalizations.guide_greenscore_lca_arg3_title,
          icon: const icons.Gears(),
          bulletPoints: <String>[
            appLocalizations.guide_greenscore_lca_arg3_text1,
            appLocalizations.guide_greenscore_lca_arg3_text2,
            appLocalizations.guide_greenscore_lca_arg3_text3,
            appLocalizations.guide_greenscore_lca_arg3_text4,
            appLocalizations.guide_greenscore_lca_arg3_text5,
            appLocalizations.guide_greenscore_lca_arg3_text6,
            appLocalizations.guide_greenscore_lca_arg3_text7,
          ],
          type: BulletPointType.arrow,
        ),
      ],
    );
  }
}

class _GreenScoreSection4 extends StatelessWidget {
  const _GreenScoreSection4();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_greenscore_bonuses_penalties_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations.guide_greenscore_bonuses_penalties_intro,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_greenscore_bonuses_penalties_arg1_title,
          icon: const icons.Factory(),
          text: appLocalizations.guide_greenscore_bonuses_penalties_arg1_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_greenscore_bonuses_penalties_arg2_title,
          icon: const icons.Origins(),
          text: appLocalizations.guide_greenscore_bonuses_penalties_arg2_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_greenscore_bonuses_penalties_arg3_title,
          icon: const icons.Monkey.sad(),
          text: appLocalizations.guide_greenscore_bonuses_penalties_arg3_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_greenscore_bonuses_penalties_arg4_title,
          icon: const icons.Packaging(),
          text: appLocalizations.guide_greenscore_bonuses_penalties_arg4_text,
        ),
      ],
    );
  }
}

class _GreenScoreSection5 extends StatelessWidget {
  const _GreenScoreSection5();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_greenscore_transparency_title,
      content: <Widget>[
        GuidesText(text: appLocalizations.guide_greenscore_transparency_intro1),
        GuidesText(text: appLocalizations.guide_greenscore_transparency_intro2),
        GuidesTitleWithText(
          title: appLocalizations.guide_greenscore_transparency_arg1_title,
          icon: const icons.Charity(),
          text: appLocalizations.guide_greenscore_transparency_arg1_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_greenscore_transparency_arg2_title,
          icon: const icons.Charity(),
          text: appLocalizations.guide_greenscore_transparency_arg2_text,
        ),
      ],
    );
  }
}
