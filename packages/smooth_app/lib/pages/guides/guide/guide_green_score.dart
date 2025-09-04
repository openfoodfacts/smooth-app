import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:vector_graphics/vector_graphics.dart';

class GuideGreenScore extends StatelessWidget {
  const GuideGreenScore({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesPage(
      pageName: 'GreenScore',
      header: const _GreenScoreHeader(),
      body: const <Widget>[
        _GreenScoreSection1(),
        _GreenScoreSection2(),
        _GreenScoreSection3(),
        _GreenScoreSection4(),
      ],
      footer: SliverToBoxAdapter(
        child: GuidesFooter(
          shareUrl: appLocalizations.guide_greenscore_share_link,
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
            child: Row(
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
          );
        },
      ),
    );
  }
}

class _GreenScoreSection2 extends StatelessWidget {
  const _GreenScoreSection2();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

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
                asset: 'assets/guides/greenscore/step_agriculture.svg',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_processing,
                asset: 'assets/guides/greenscore/step_processing.svg',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_packaging,
                asset: 'assets/guides/greenscore/step_packaging.svg',
              ),
              GuidesGridItem(
                label:
                    appLocalizations.guide_greenscore_lca_arg2_transportation,
                asset: 'assets/guides/greenscore/step_transportation.svg',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_distribution,
                asset: 'assets/guides/greenscore/step_distribution.svg',
              ),
              GuidesGridItem(
                label: appLocalizations.guide_greenscore_lca_arg2_consumption,
                asset: 'assets/guides/greenscore/step_consumption.svg',
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

class _GreenScoreSection3 extends StatelessWidget {
  const _GreenScoreSection3();

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
          icon: const icons.Manufacturing(),
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

class _GreenScoreSection4 extends StatelessWidget {
  const _GreenScoreSection4();

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
