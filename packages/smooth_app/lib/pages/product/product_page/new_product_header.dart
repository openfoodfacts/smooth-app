import 'dart:math' as math;

import 'package:flutter/material.dart' hide Listener;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProductHeaderDelegate extends SliverPersistentHeaderDelegate {
  ProductHeaderDelegate({required this.statusBarHeight, this.backButtonType})
    : assert(statusBarHeight >= 0.0);

  final double statusBarHeight;
  final BackButtonType? backButtonType;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _ProductHeader(backButtonType: backButtonType);
  }

  @override
  double get minExtent => kToolbarHeight + statusBarHeight;

  @override
  double get maxExtent => minExtent;

  @override
  bool shouldRebuild(ProductHeaderDelegate oldDelegate) => false;
}

class _ProductHeader extends StatefulWidget {
  const _ProductHeader({this.backButtonType});

  final BackButtonType? backButtonType;

  @override
  State<_ProductHeader> createState() => _ProductHeaderState();
}

class _ProductHeaderState extends State<_ProductHeader> {
  double _titleOpacity = 0.0;
  double _compatibilityScoreOpacity = 0.0;
  double _shadow = 0.0;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.viewPaddingOf(context).top;

    return VisibilityDetector(
      key: const Key('product_header'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Listener<ScrollController>(
        listener: (_, _, ScrollController scrollController) =>
            _onScroll(scrollController),
        child: Consumer<ProductPageCompatibility>(
          builder:
              (
                BuildContext context,
                ProductPageCompatibility productCompatibility,
                _,
              ) {
                final Color tintColor = _getTintColor(
                  productCompatibility,
                  context,
                );

                return Material(
                  color: tintColor,
                  shadowColor: tintColor,
                  elevation: _shadow,
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(color: Colors.white),
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.white),
                      child: SizedBox(
                        height: kToolbarHeight + statusBarHeight,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: statusBarHeight,
                          ),
                          child: Row(
                            children: <Widget>[
                              SmoothBackButton(
                                backButtonType: widget.backButtonType,
                              ),
                              Expanded(
                                child: Offstage(
                                  offstage: _titleOpacity == 0.0,
                                  child: Opacity(
                                    opacity: _titleOpacity,
                                    child: const _ProductHeaderName(),
                                  ),
                                ),
                              ),
                              if (productCompatibility.score != null)
                                _ProductCompatibilityScore(
                                  progress: _compatibilityScoreOpacity,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
        ),
      ),
    );
  }

  Color _getTintColor(
    ProductPageCompatibility productCompatibility,
    BuildContext context,
  ) {
    final Color? tintColor = productCompatibility.color;
    if (tintColor != null) {
      return tintColor;
    }

    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    return context.lightTheme() ? theme.primaryBlack : theme.primaryUltraBlack;
  }

  void _onScroll(ScrollController scrollController) {
    /// Get the title opacity depending on the scroll position
    final double titleOpacity = scrollController.offset.progressAndClamp(
      LARGE_SPACE * 2 + kToolbarHeight * 0.22,
      LARGE_SPACE * 2 + kToolbarHeight * 1.5,
      1.0,
    );
    final double compatibilityScoreOpacity = scrollController.offset
        .progressAndClamp(
          LARGE_SPACE * 1.5,
          LARGE_SPACE + kToolbarHeight * 2,
          1.0,
        );
    final double shadow = scrollController.offset.progressAndClamp(
      0.0,
      kToolbarHeight / 2,
      2.0,
    );

    if (_titleOpacity != titleOpacity ||
        _compatibilityScoreOpacity != compatibilityScoreOpacity ||
        _shadow != shadow) {
      _titleOpacity = titleOpacity;
      _compatibilityScoreOpacity = compatibilityScoreOpacity;
      _shadow = shadow;

      // Calling setState() may already be in a build() call
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  /// Change the status bar to a transparent one
  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction == 1.0) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    }
  }
}

class _ProductHeaderName extends StatelessWidget {
  const _ProductHeaderName();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 4.0),
      child: ConsumerFilter<Product>(
        buildWhen: (Product? previousValue, Product currentValue) {
          return previousValue?.brands != currentValue.brands ||
              previousValue?.productName != currentValue.productName;
        },
        builder: (BuildContext context, Product product, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                getProductName(product, appLocalizations),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                  height: 1.0,
                ),
                strutStyle: const StrutStyle(forceStrutHeight: true),
              ),
              Text(
                getProductBrands(product, appLocalizations),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16.5),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCompatibilityScore extends StatelessWidget {
  const _ProductCompatibilityScore({required this.progress});

  //ignore: constant_identifier_names
  static const double MAX_WIDTH = 40.0;
  static const EdgeInsetsGeometry PADDING = EdgeInsetsDirectional.only(
    start: MEDIUM_SPACE,
    end: BALANCED_SPACE,
  );

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ProductPageCompatibility compatibility = context
        .watch<ProductPageCompatibility>();

    final String tooltipMessage = AppLocalizations.of(
      context,
    ).product_page_compatibility_score_tooltip(compatibility.score!);

    return Semantics(
      excludeSemantics: true,
      button: true,
      label: tooltipMessage,
      child: Tooltip(
        message: tooltipMessage,
        child: Padding(
          padding: PADDING,
          child: SizedBox(
            width: computeWidth(context) + (MAX_WIDTH * progress),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: ROUNDED_BORDER_RADIUS,
                border: Border.all(color: Colors.white),
              ),
              child: InkWell(
                onTap: () =>
                    AppNavigator.of(context).push(AppRoutes.FOOD_PREFERENCES),
                borderRadius: ROUNDED_BORDER_RADIUS,
                child: ClipRRect(
                  borderRadius: ROUNDED_BORDER_RADIUS,
                  child: _getScoreWidget(context, compatibility),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getScoreWidget(
    BuildContext context,
    ProductPageCompatibility compatibility,
  ) {
    final String compatibilityLabel = AppLocalizations.of(
      context,
    ).product_page_compatibility_score;

    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Opacity(
            opacity: progress,
            child: Container(
              width: MAX_WIDTH * progress,
              height: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsetsDirectional.only(start: 2.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: Radius.circular(18.0),
                ),
              ),
              child: Transform.translate(
                offset: Offset((1 - progress) * 10, 0.0),
                child: SizedBox(child: icons.Info(color: compatibility.color)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 6.0,
                bottom: SMALL_SPACE,
                start: 5.0,
                end: 6.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${compatibility.score}%',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 12.0,
                      height: 0.9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      compatibilityLabel,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        height: 1.0,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double computeWidth(BuildContext context) {
    return math.min(
      90.0,
      (MediaQuery.sizeOf(context).width - PADDING.horizontal) * (20 / 100),
    );
  }
}

enum ProductPageTransition {
  standard,
  slideUp;

  static ProductPageTransition byName(String? type) {
    return switch (type) {
      'slideUp' => ProductPageTransition.slideUp,
      _ => ProductPageTransition.standard,
    };
  }
}
