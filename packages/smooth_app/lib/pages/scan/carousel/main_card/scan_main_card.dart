import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/helpers/strings_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/scan_tagline.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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
                      SizedBox(height: MEDIUM_SPACE),
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
          FormattedText(
            text: localizations.homepage_main_card_subheading,
            textAlign: TextAlign.center,
            textStyle: const TextStyle(height: 1.3),
          ),
          const _SearchBar(),
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

  static const double SEARCH_BAR_HEIGHT = 47.0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final bool lightTheme = !context.watch<ThemeProvider>().isDarkMode(context);

    return Semantics(
      button: true,
      child: SizedBox(
        height: SEARCH_BAR_HEIGHT,
        child: InkWell(
          onTap: () => AppNavigator.of(context).push(AppRoutes.SEARCH),
          borderRadius: BorderRadius.circular(30.0),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: lightTheme ? Colors.white : theme.greyDark,
              border: Border.all(color: theme.primaryBlack),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 20.0,
                      end: 10.0,
                      bottom: 3.0,
                    ),
                    child: Text(
                      localizations.homepage_main_card_search_field_hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: lightTheme ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 1.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Search(
                        size: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
