import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:vector_graphics/vector_graphics.dart';

class GuideNOVA extends StatelessWidget {
  const GuideNOVA({super.key});

  @override
  Widget build(BuildContext context) {
    return GuidesPage(
      pageName: 'NOVA',
      header: const _NOVAHeader(),
      body: const <Widget>[_NOVASection1(), _NOVASection2(), _NOVASection3()],
      footer: SliverToBoxAdapter(
        child: GuidesFooter(
          shareUrl: ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/nova',
          ),
        ),
      ),
    );
  }
}

class _NOVAHeader extends StatelessWidget {
  const _NOVAHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesHeader(
      title: appLocalizations.guide_nova_title,
      illustration: const _NOVAHeaderIllustration(),
    );
  }
}

class _NOVAHeaderIllustration extends StatelessWidget {
  const _NOVAHeaderIllustration();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: VERY_LARGE_SPACE,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SvgPicture(
                    AssetBytesLoader('assets/guides/nova/nova_1.svg.vec'),
                  ),
                ),
                Expanded(
                  child: SvgPicture(
                    AssetBytesLoader('assets/guides/nova/nova_2.svg.vec'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SvgPicture(
                    AssetBytesLoader('assets/guides/nova/nova_3.svg.vec'),
                  ),
                ),
                Expanded(
                  child: SvgPicture(
                    AssetBytesLoader('assets/guides/nova/nova_4.svg.vec'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NOVASection1 extends StatelessWidget {
  const _NOVASection1();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_nova_what_is_nova_title,
      content: <Widget>[
        GuidesText(text: appLocalizations.guide_nova_what_is_nova_paragraph1),
        GuidesText(text: appLocalizations.guide_nova_what_is_nova_paragraph2),
        const _NOVALogos(),
      ],
    );
  }
}

class _NOVALogos extends StatelessWidget {
  const _NOVALogos();

  static const List<String> assets = <String>[
    'assets/guides/nova/nova_1_min.svg.vec',
    'assets/guides/nova/nova_2_min.svg.vec',
    'assets/guides/nova/nova_3_min.svg.vec',
    'assets/guides/nova/nova_4_min.svg.vec',
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesCaptionContainer(
      caption: appLocalizations.guide_nova_logos_caption,
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
                          height: 50.0,
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

class _NOVASection2 extends StatelessWidget {
  const _NOVASection2();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_nova_groups_title,
      content: <Widget>[
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_groups_arg1_title,
          icon: const icons.FoodIcons.nova1(),
          text: appLocalizations.guide_nova_groups_arg2_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_groups_arg2_title,
          icon: const icons.FoodIcons.nova2(),
          text: appLocalizations.guide_nova_groups_arg2_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_groups_arg3_title,
          icon: const icons.FoodIcons.nova3(),
          text: appLocalizations.guide_nova_groups_arg3_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_groups_arg4_title,
          icon: const icons.FoodIcons.nova4(),
          text: appLocalizations.guide_nova_groups_arg4_text,
        ),
      ],
    );
  }
}

class _NOVASection3 extends StatelessWidget {
  const _NOVASection3();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_nova_explanations_title,
      content: <Widget>[
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_explanations_arg1_title,
          icon: const icons.Lab.alt(),
          text: appLocalizations.guide_nova_explanations_arg1_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_explanations_arg2_title,
          icon: const icons.Lab.alt(),
          text: appLocalizations.guide_nova_explanations_arg2_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_explanations_arg3_title,
          icon: const icons.Lab.alt(),
          text: appLocalizations.guide_nova_explanations_arg3_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_explanations_arg4_title,
          icon: const icons.Lab.alt(),
          text: appLocalizations.guide_nova_explanations_arg4_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_explanations_arg5_title,
          icon: const icons.Hearth.monitoring(),
          text: appLocalizations.guide_nova_explanations_arg5_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nova_explanations_arg6_title,
          icon: const icons.Thumb.up(),
          text: appLocalizations.guide_nova_explanations_arg6_text,
        ),
      ],
    );
  }
}
