import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/scan_tagline.dart';
import 'package:smooth_app/pages/search/search_field.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/pages/search/search_product_helper.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class ScanMainCard extends StatelessWidget {
  const ScanMainCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ConsumerFilter<AppNewsProvider>(
            buildWhen:
                (AppNewsProvider? previousValue, AppNewsProvider currentValue) {
              return previousValue?.hasContent != currentValue.hasContent;
            },
            builder: (BuildContext context, AppNewsProvider newsFeed, _) {
              if (!newsFeed.hasContent) {
                return const _SearchCard(
                  expandedMode: true,
                );
              } else {
                return Semantics(
                  explicitChildNodes: true,
                  child: const Column(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: _SearchCard(
                          expandedMode: false,
                        ),
                      ),
                      SizedBox(height: SMALL_SPACE),
                      Expanded(
                        flex: 4,
                        child: ScanTagLine(),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.expandedMode,
  });

  /// Expanded is when this card is the only one (no tagline, no app review…)
  final bool expandedMode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool lightTheme = !context.watch<ThemeProvider>().isDarkMode(context);

    final Widget widget = SmoothCard(
      color: lightTheme ? Colors.grey.withOpacity(0.1) : Colors.black,
      padding: const EdgeInsets.symmetric(
        vertical: MEDIUM_SPACE,
        horizontal: LARGE_SPACE,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 0.0,
        vertical: VERY_SMALL_SPACE,
      ),
      ignoreDefaultSemantics: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SvgPicture.asset(
            lightTheme
                ? 'assets/app/logo_text_black.svg'
                : 'assets/app/logo_text_white.svg',
            semanticsLabel: localizations.homepage_main_card_logo_description,
          ),
          TextWithBoldParts(
            text: localizations.homepage_main_card_subheading,
            textAlign: TextAlign.center,
            textStyle: const TextStyle(height: 1.3),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: SMALL_SPACE),
            child: _SearchBar(),
          ),
        ],
      ),
    );

    if (expandedMode) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.4,
        ),
        child: widget,
      );
    } else {
      return widget;
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  static const String HERO_TAG = 'search_field';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Semantics(
      button: true,
      child: Hero(
        tag: HERO_TAG,
        child: Material(
          // ↑ Needed by the Hero Widget
          type: MaterialType.transparency,
          child: SizedBox(
            height: SearchFieldUIHelper.SEARCH_BAR_HEIGHT,
            child: InkWell(
              onTap: () => AppNavigator.of(context).push(
                AppRoutes.SEARCH,
                extra: SearchPageExtra(
                  searchHelper: SearchProductHelper(),
                  autofocus: true,
                  heroTag: HERO_TAG,
                ),
              ),
              borderRadius: SearchFieldUIHelper.SEARCH_BAR_BORDER_RADIUS,
              child: Ink(
                decoration: SearchFieldUIHelper.decoration(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: SearchFieldUIHelper.SEARCH_BAR_PADDING,
                        child: Text(
                          localizations.homepage_main_card_search_field_hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SearchFieldUIHelper.textStyle(context),
                        ),
                      ),
                    ),
                    const SearchBarIcon(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
