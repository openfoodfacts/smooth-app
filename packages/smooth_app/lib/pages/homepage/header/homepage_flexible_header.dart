import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/pages/homepage/header/homepage_header_bottom.dart';
import 'package:smooth_app/pages/homepage/header/homepage_header_logo.dart';
import 'package:smooth_app/pages/homepage/header/homepage_header_searchbar.dart';
import 'package:smooth_app/pages/homepage/homepage.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class HomePageFlexibleHeader extends StatelessWidget {
  const HomePageFlexibleHeader({super.key, this.footer});

  final HomePageSearchBarBottomWidget? footer;

  static const double HEIGHT =
      HomePageAppLogo.MAX_HEIGHT + HomePageHeaderSearchBar.SEARCH_BAR_HEIGHT;
  static const EdgeInsetsDirectional CONTENT_PADDING =
      EdgeInsetsDirectional.symmetric(
        horizontal: HomePage.HORIZONTAL_PADDING - 4.0,
      );
  static const EdgeInsetsDirectional MIN_CONTENT_PADDING =
      EdgeInsetsDirectional.symmetric(horizontal: 10.0);
  static const EdgeInsetsDirectional LOGO_CONTENT_PADDING =
      EdgeInsetsDirectional.only(start: 4.0, end: 10.0);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _HomePageHeaderSliver(
        topPadding: MediaQuery.paddingOf(context).top,
        footer: footer,
      ),
      pinned: true,
    );
  }
}

class _HomePageHeaderSliver extends SliverPersistentHeaderDelegate {
  const _HomePageHeaderSliver({required this.topPadding, this.footer});

  final double topPadding;
  final HomePageSearchBarBottomWidget? footer;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Selector<ScrollController, (double, double)>(
      selector: (BuildContext context, ScrollController controller) {
        final double position = controller.offset;
        final HomePageState homePageState = HomePage.of(context);
        final double cameraHeight = homePageState.cameraHeight;
        final double cameraPeak = homePageState.cameraPeak;

        if (position >= cameraHeight) {
          return (1.0, shrinkOffset);
        } else if (position < cameraPeak) {
          return (0.0, shrinkOffset);
        } else {
          return (
            (position - cameraPeak) / (cameraHeight - cameraPeak),
            shrinkOffset,
          );
        }
      },
      shouldRebuild: ((double, double) previous, (double, double) next) {
        return previous.$1 != next.$1 ||
            footer != null && previous.$2 != next.$2;
      },
      builder: (BuildContext context, (double, double) progress, _) {
        return _build(
          context: context,
          progress: progress.$1,
          autofocus: false,
          shrinkOffset: progress.$2,
        );
      },
    );
  }

  Widget _build({
    required BuildContext context,
    required double progress,
    required bool autofocus,
    required double shrinkOffset,
  }) {
    final double max = maxExtent - minExtent;

    return _HomePageHeaderBody(
      progress: progress,
      topPadding: topPadding,
      minExtent: minExtent,
      autofocus: autofocus,
      footer: shrinkOffset < max ? footer : null,
      footerOffset: footer == null || shrinkOffset >= max
          ? null
          : shrinkOffset.clamp(0.0, max),
      footerMaxOffset: footer != null ? max : null,
    );
  }

  @override
  double get maxExtent =>
      minExtent +
      (footer == null ? 0 : (footer!.height + HomePage.BORDER_RADIUS));

  @override
  double get minExtent => HomePageFlexibleHeader.HEIGHT + (topPadding * 1.5);

  @override
  bool shouldRebuild(_HomePageHeaderSliver oldDelegate) =>
      oldDelegate.footer != footer;
}

class _HomePageHeaderBody extends StatelessWidget {
  const _HomePageHeaderBody({
    required this.progress,
    required this.autofocus,
    required this.minExtent,
    required this.topPadding,
    this.footer,
    this.footerOffset,
    this.footerMaxOffset,
  });

  final HomePageSearchBarBottomWidget? footer;
  final double topPadding;
  final double? footerOffset;
  final double? footerMaxOffset;
  final double minExtent;
  final bool autofocus;

  final double progress;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final bool invisibleFooter =
        footer == null || footerOffset! >= footerMaxOffset!;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          top:
              minExtent -
              topPadding -
              (HomePage.BORDER_RADIUS / 2) -
              (footerOffset ?? 0.0),
          bottom: 0.0,
          child: Offstage(
            offstage: invisibleFooter,
            child: SafeArea(
              bottom: false,
              child: HomePageHeaderBottomWidgetWrapper(child: footer),
            ),
          ),
        ),
        Positioned.fill(
          top: 0.0,
          bottom: footer != null && footerOffset! < footerMaxOffset!
              ? footer!.height - footerOffset! + HomePage.BORDER_RADIUS
              : 0.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: lightTheme ? theme.primaryMedium : theme.primaryUltraBlack,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(HomePage.BORDER_RADIUS),
              ),
              boxShadow: invisibleFooter
                  ? <BoxShadow>[
                      BoxShadow(
                        color: lightTheme
                            ? const Color(0x44FFFFFF)
                            : const Color(0x44000000),
                        blurRadius: progress * 10.0,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  height:
                      MediaQuery.viewPaddingOf(context).top /
                      progress.progress2(2, 1),
                ),
                Expanded(child: HomePageHeaderLogo(progress: progress)),
                SizedBox(
                  height:
                      (1 - progress) *
                      (MediaQuery.viewPaddingOf(context).top / 6),
                ),
                HomePageHeaderSearchBar(
                  progress: progress,
                  autofocus: autofocus,
                ),
                SizedBox(
                  height:
                      (1 - progress.clamp(0.0, 0.7)) *
                      (MediaQuery.viewPaddingOf(context).top / 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
