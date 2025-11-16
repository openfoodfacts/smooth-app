import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vector_graphics/vector_graphics.dart';

class GuideOpenProductsFacts extends StatelessWidget {
  const GuideOpenProductsFacts({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesPage.smallHeader(
      pageName: 'OpenProductsFacts',
      header: const _OpenProductsFactsHeader(),
      body: const <Widget>[
        _OpenProductsFactsSection1(),
        _OpenProductsFactsSection2(),
        _OpenProductsFactsSection3(),
        _OpenProductsFactsSection4(),
      ],
      footer: SliverToBoxAdapter(
        child: GuidesFooter(
          shareUrl: appLocalizations.guide_open_products_facts_share_link,
        ),
      ),
    );
  }
}

class _OpenProductsFactsHeader extends StatelessWidget {
  const _OpenProductsFactsHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesHeader(
      title: appLocalizations.guide_open_products_facts_title,
      illustration: const _OpenProductsFactsHeaderIllustration(),
    );
  }
}

class _OpenProductsFactsHeaderIllustration extends StatelessWidget {
  const _OpenProductsFactsHeaderIllustration();

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
                'assets/guides/open_products_facts/open_products_facts_logo.svg.vec',
              ),
              width: 140.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenProductsFactsSection1 extends StatelessWidget {
  const _OpenProductsFactsSection1();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations
          .guide_open_products_facts_what_is_open_products_facts_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations
              .guide_open_products_facts_what_is_open_products_facts_paragraph1,
        ),
        GuidesText(
          text: appLocalizations
              .guide_open_products_facts_what_is_open_products_facts_paragraph2,
        ),
        const Padding(
          padding: EdgeInsetsDirectional.only(top: LARGE_SPACE),
          child: SvgPicture(
            AssetBytesLoader(
              'assets/guides/open_products_facts/washing_machine.svg.vec',
            ),
            width: 80.0,
          ),
        ),
      ],
    );
  }
}

class _OpenProductsFactsSection2 extends StatelessWidget {
  const _OpenProductsFactsSection2();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_products_facts_features_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations.guide_open_products_facts_features_text,
        ),
        GuidesTitleWithText(
          icon: const icons.Environment.alt(),
          title: appLocalizations.guide_open_products_facts_features_arg1_title,
          text: appLocalizations.guide_open_products_facts_features_arg1_text,
        ),
        GuidesImage(
          imagePath: 'assets/guides/open_products_facts/impact_co2.svg.vec',
          caption: appLocalizations.guide_learn_more_subtitle,
          desiredWidthPercent: 0.3,
          onTap: () => launchUrlString('https://impactco2.fr/'),
        ),
        GuidesTitleWithText(
          icon: const icons.Toolbox(),
          title: appLocalizations.guide_open_products_facts_features_arg2_title,
          text: appLocalizations.guide_open_products_facts_features_arg2_text,
        ),
        GuidesImage(
          imagePath:
              'assets/guides/open_products_facts/reparability_index.svg.vec',
          caption: appLocalizations.guide_learn_more_subtitle,
          desiredWidthPercent: 0.3,
          onTap: () => launchUrlString(
            'https://www.ecologie.gouv.fr/politiques-publiques/indice-reparabilite',
          ),
        ),
        GuidesTitleWithText(
          icon: const icons.Donate(),
          title: appLocalizations.guide_open_products_facts_features_arg3_title,
          text: appLocalizations.guide_open_products_facts_features_arg3_text,
        ),
      ],
    );
  }
}

class _OpenProductsFactsSection3 extends StatelessWidget {
  const _OpenProductsFactsSection3();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_products_facts_information_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations.guide_open_products_facts_information_text,
        ),
      ],
    );
  }
}

class _OpenProductsFactsSection4 extends StatelessWidget {
  const _OpenProductsFactsSection4();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_products_facts_folksonomy_title,
      content: <Widget>[
        GuidesText(
          text:
              appLocalizations.guide_open_products_facts_folksonomy_paragraph1,
        ),
        GuidesText(
          text:
              appLocalizations.guide_open_products_facts_folksonomy_paragraph2,
        ),
        GuidesText(
          text:
              appLocalizations.guide_open_products_facts_folksonomy_paragraph3,
        ),
      ],
    );
  }
}
