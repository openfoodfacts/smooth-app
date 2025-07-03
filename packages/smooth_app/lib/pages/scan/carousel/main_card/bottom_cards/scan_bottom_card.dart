import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/app_review.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/news/scan_news_card.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/news/scan_news_provider.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/scan_app_review_card.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ScanBottomCard extends StatelessWidget {
  const ScanBottomCard({required this.dense, super.key});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ScanNewsFeedProvider>(
          create: (BuildContext context) => ScanNewsFeedProvider(context),
        ),
        Provider<ScanBottomCardDensity>(
          create: (_) => dense
              ? ScanBottomCardDensity.dense
              : ScanBottomCardDensity.normal,
        ),
      ],
      child: Consumer2<ScanNewsFeedProvider, AppReviewProvider>(
        builder:
            (
              BuildContext context,
              ScanNewsFeedProvider scanTagLineProvider,
              AppReviewProvider appReviewProvider,
              Widget? child,
            ) {
              switch (appReviewProvider.value) {
                case AppReviewState.checking:
                  return const ScanBottomCardLoading();
                case AppReviewState.askForReview:
                  return const ScanAppReview();
                default:
                // Nothing (-> news)
              }

              final ScanTagLineState state = scanTagLineProvider.value;

              return switch (state) {
                ScanTagLineStateLoading() => const ScanBottomCardLoading(),
                ScanTagLineStateNoContent() => EMPTY_WIDGET,
                ScanTagLineStateLoaded() => ScanNewsCard(news: state.tagLine),
              };
            },
      ),
    );
  }
}

enum ScanBottomCardDensity { dense, normal }

class ScanBottomCardLoading extends StatelessWidget {
  const ScanBottomCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final ScanBottomCardDensity density = context.read<ScanBottomCardDensity>();

    return Shimmer.fromColors(
      baseColor: context.extension<SmoothColorsThemeExtension>().primaryMedium,
      highlightColor: Colors.white,
      child: SmoothCard(
        margin: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          height: density == ScanBottomCardDensity.dense
              ? 200.0
              : double.infinity,
        ),
      ),
    );
  }
}

class ScanBottomCardContainer extends StatelessWidget {
  const ScanBottomCardContainer({
    required this.title,
    required this.body,
    this.titleBackgroundColor,
    this.titleIndicatorColor,
    this.titleColor,
    this.backgroundColor,
    this.onClose,
    super.key,
  });

  final String title;
  final Widget body;
  final Color? titleBackgroundColor;
  final Color? titleIndicatorColor;
  final Color? titleColor;
  final Color? backgroundColor;
  final VoidCallback? onClose;

  // Default values seem weird
  static const Radius radius = Radius.circular(16.0);

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    final bool dense =
        context.read<ScanBottomCardDensity>() == ScanBottomCardDensity.dense;

    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color:
                titleBackgroundColor ??
                (context.lightTheme()
                    ? extension.primarySemiDark
                    : extension.secondaryVibrant),
            borderRadius: const BorderRadiusDirectional.only(
              topStart: radius,
              topEnd: radius,
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: dense ? LARGE_SPACE : MEDIUM_SPACE,
              end: dense ? MEDIUM_SPACE : BALANCED_SPACE,
              top: VERY_SMALL_SPACE,
              bottom: VERY_SMALL_SPACE,
            ),
            child: _ScanBottomCardContainerTitle(
              title: title,
              backgroundColor: titleBackgroundColor,
              indicatorColor: titleIndicatorColor,
              titleColor: titleColor,
              onClose: onClose,
            ),
          ),
        ),
        _buildBody(context: context, dense: dense, extension: extension),
      ],
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required bool dense,
    required SmoothColorsThemeExtension extension,
  }) {
    final Widget child = Material(
      type: MaterialType.card,
      color:
          backgroundColor ??
          (context.lightTheme()
              ? extension.primaryMedium
              : extension.primaryUltraBlack),
      borderRadius: const BorderRadius.vertical(bottom: radius),
      child: body,
    );

    if (dense) {
      return child;
    } else {
      return Expanded(child: child);
    }
  }
}

class _ScanBottomCardContainerTitle extends StatelessWidget {
  const _ScanBottomCardContainerTitle({
    required this.title,
    this.backgroundColor,
    this.indicatorColor,
    this.titleColor,
    this.onClose,
  });

  final String title;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? titleColor;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final bool dense =
        context.read<ScanBottomCardDensity>() == ScanBottomCardDensity.dense;

    final AppLocalizations localizations = AppLocalizations.of(context);

    return Semantics(
      label: localizations.scan_tagline_news_item_accessibility(title),
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: dense ? 28.0 : 30.0),
        child: Row(
          children: <Widget>[
            SizedBox.square(
              dimension: 11.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: indicatorColor ?? Colors.white,
                  borderRadius: const BorderRadius.all(ROUNDED_RADIUS),
                ),
              ),
            ),
            const SizedBox(width: BALANCED_SPACE),
            Expanded(
              child: AutoSizeText(
                title,
                maxLines: 1,
                minFontSize: 8.0,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: titleColor ?? Colors.white,
                ),
              ),
            ),
            if (onClose != null) ...<Widget>[
              const SizedBox(width: VERY_SMALL_SPACE),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: Tooltip(
                    message: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
                      child: Close(
                        size: 11.0,
                        color: titleColor ?? Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
