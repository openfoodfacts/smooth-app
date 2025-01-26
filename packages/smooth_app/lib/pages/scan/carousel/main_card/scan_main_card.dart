import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
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
    return ConsumerFilter<AppNewsProvider>(
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
            child: LayoutBuilder(
              builder: (_, BoxConstraints constraints) {
                final bool dense = constraints.maxHeight * 0.4 <=
                    _maxHeight(context.textScaler());

                if (dense) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(
                            _SearchCard.computeMinSize(context),
                            constraints.maxHeight * 0.5,
                          ),
                        ),
                        child: const _SearchCard(
                          expandedMode: false,
                        ),
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      const ScanTagLine(dense: true),
                    ],
                  );
                } else {
                  return const Column(
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
                        child: ScanTagLine(dense: false),
                      ),
                    ],
                  );
                }
              },
            ),
          );
        }
      },
    );
  }

  double _maxHeight(double textScaler) {
    if (textScaler < 1.1) {
      return 160.0;
    } else if (textScaler < 1.3) {
      return 173.0;
    } else {
      return 186.0;
    }
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
      color: lightTheme ? Colors.grey.withValues(alpha: 0.1) : Colors.black,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(
        horizontal: 0.0,
        vertical: VERY_SMALL_SPACE,
      ),
      ignoreDefaultSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: MEDIUM_SPACE,
          horizontal: LARGE_SPACE,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            LayoutBuilder(builder: (_, BoxConstraints constraints) {
              return SvgPicture.asset(
                lightTheme
                    ? 'assets/app/logo_text_black.svg'
                    : 'assets/app/logo_text_white.svg',
                width: math.min(311.0, constraints.maxWidth * 0.85),
                semanticsLabel:
                    localizations.homepage_main_card_logo_description,
              );
            }),
            const SizedBox(height: VERY_SMALL_SPACE),
            TextWithBoldParts(
              text: localizations.homepage_main_card_subheading,
              textAlign: TextAlign.center,
              textStyle: const TextStyle(height: 1.6, fontSize: 15.0),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: SMALL_SPACE),
              child: _SearchBar(),
            ),
          ],
        ),
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

  static double computeMinSize(BuildContext context, {bool expanded = false}) {
    if (expanded) {
      return MediaQuery.sizeOf(context).height * 0.4;
    } else {
      return (MEDIUM_SPACE * 3) +
          (VERY_SMALL_SPACE * 3) +
          // Logo
          54.0 +
          // Text
          ((2 * DefaultTextStyle.of(context).style.fontSize!) * 1.3) *
              context.textScaler() +
          // Search bar
          SearchFieldUIHelper.SEARCH_BAR_HEIGHT +
          // Extra space
          VERY_LARGE_SPACE;
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
                          textScaler: TextScaler.noScaling,
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
