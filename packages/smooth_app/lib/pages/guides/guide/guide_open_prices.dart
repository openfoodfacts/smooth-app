import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class GuideOpenPrices extends StatelessWidget {
  const GuideOpenPrices({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesPage(
      pageName: 'OpenPrices',
      header: const _OpenPricesHeader(),
      body: const <Widget>[
        _OpenPricesSection1(),
        _OpenPricesSection2(),
        _OpenPricesSection3(),
        _OpenPricesSection4(),
        _OpenPricesSection5(),
      ],
      footer: SliverToBoxAdapter(
        child: GuidesFooter(
          shareUrl: appLocalizations.guide_open_prices_share_link,
        ),
      ),
    );
  }
}

class _OpenPricesHeader extends StatelessWidget {
  const _OpenPricesHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesHeader(
      title: appLocalizations.guide_open_prices_title,
      illustration: const _OpenPricesHeaderIllustration(),
    );
  }
}

class _OpenPricesHeaderIllustration extends StatelessWidget {
  const _OpenPricesHeaderIllustration();

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
              'assets/guides/open_prices/open_prices_logo.svg',
              width: 120.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenPricesSection1 extends StatelessWidget {
  const _OpenPricesSection1();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_prices_what_is_open_prices_title,
      content: <Widget>[
        GuidesText(
          text:
              appLocalizations.guide_open_prices_what_is_open_prices_paragraph1,
        ),
        GuidesText(
          text:
              appLocalizations.guide_open_prices_what_is_open_prices_paragraph2,
        ),
      ],
    );
  }
}

class _OpenPricesSection2 extends StatelessWidget {
  const _OpenPricesSection2();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_prices_how_title,
      content: <Widget>[
        GuidesText(text: appLocalizations.guide_open_prices_how_paragraph1),
        GuidesTitleWithText(
          icon: const icons.Milk.happy(),
          title: appLocalizations.guide_open_prices_how_arg1_title,
          text: '',
        ),
        GuidesTitleWithText(
          icon: const icons.Soda.happy(),
          title: appLocalizations.guide_open_prices_how_arg2_title,
          text: '',
        ),
      ],
    );
  }
}

class _OpenPricesSection3 extends StatelessWidget {
  const _OpenPricesSection3();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_prices_why_title,
      content: <Widget>[
        GuidesText(text: appLocalizations.guide_open_prices_why_paragraph1),
        GuidesTitleWithText(
          title: appLocalizations.guide_open_prices_why_arg1_title,
          icon: const icons.Salt(),
          text: appLocalizations.guide_open_prices_why_arg1_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_open_prices_why_arg2_title,
          icon: const icons.Fish(),
          text: appLocalizations.guide_open_prices_why_arg2_text,
        ),
      ],
    );
  }
}

class _OpenPricesSection4 extends StatelessWidget {
  const _OpenPricesSection4();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_prices_scrapping_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations.guide_open_prices_scrapping_paragraph1,
        ),
        GuidesText(
          text: appLocalizations.guide_open_prices_scrapping_paragraph2,
        ),
      ],
    );
  }
}

class _OpenPricesSection5 extends StatelessWidget {
  const _OpenPricesSection5();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_open_prices_retailers_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations.guide_open_prices_retailers_paragraph1,
        ),
      ],
    );
  }
}
