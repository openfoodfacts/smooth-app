import 'dart:math' as math;

import 'package:flutter/material.dart' hide Listener;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProductHeader extends StatefulWidget {
  const ProductHeader({
    this.backButtonType,
    super.key,
  });

  final ProductPageBackButton? backButtonType;

  @override
  State<ProductHeader> createState() => _ProductHeaderState();
}

class _ProductHeaderState extends State<ProductHeader> {
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
        listener: (
          _,
          __,
          ScrollController scrollController,
        ) =>
            _onScroll(scrollController),
        child: Consumer<ProductPageCompatibility>(
          builder: (
            BuildContext context,
            ProductPageCompatibility productCompatibility,
            _,
          ) {
            final Color tintColor = productCompatibility.color ??
                Theme.of(context)
                    .extension<SmoothColorsThemeExtension>()!
                    .greyNormal;

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
                      padding: EdgeInsetsDirectional.only(top: statusBarHeight),
                      child: Row(
                        children: <Widget>[
                          _ProductHeaderBackButton(
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

  void _onScroll(ScrollController scrollController) {
    /// Get the title opacity depending on the scroll position
    final double titleOpacity = scrollController.offset.progressAndClamp(
      LARGE_SPACE * 2 + kToolbarHeight * 0.22,
      LARGE_SPACE * 2 + kToolbarHeight * 1.5,
      1.0,
    );
    final double compatibilityScoreOpacity =
        scrollController.offset.progressAndClamp(
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

class _ProductHeaderBackButton extends StatelessWidget {
  const _ProductHeaderBackButton({
    this.backButtonType,
  });

  final ProductPageBackButton? backButtonType;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: MaterialLocalizations.of(context).backButtonTooltip,
      excludeSemantics: true,
      button: true,
      child: SizedBox(
        width: 56.0,
        child: Tooltip(
          message: MaterialLocalizations.of(context).backButtonTooltip,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.of(context).maybePop();
            },
            child: SizedBox.expand(
              child: backButtonType == ProductPageBackButton.minimize
                  ? const icons.Chevron.down(size: 16.0)
                  : Icon(ConstantIcons.instance.getBackIcon()),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductHeaderName extends StatelessWidget {
  const _ProductHeaderName();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ConsumerFilter<Product>(
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
                height: 0.9,
              ),
            ),
            Text(
              getProductBrands(product, appLocalizations),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCompatibilityScore extends StatelessWidget {
  const _ProductCompatibilityScore({
    required this.progress,
  });

  //ignore: constant_identifier_names
  static const double MAX_WIDTH = 40.0;
  static const EdgeInsetsGeometry PADDING = EdgeInsetsDirectional.only(
    start: MEDIUM_SPACE,
    end: BALANCED_SPACE,
  );

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ProductPageCompatibility compatibility =
        context.watch<ProductPageCompatibility>();

    final String tooltipMessage =
        AppLocalizations.of(context).product_page_compatibility_score_tooltip(
      compatibility.score!,
    );

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
                onTap: () => AppNavigator.of(context).push(
                  AppRoutes.PREFERENCES(PreferencePageType.FOOD),
                ),
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
                child: SizedBox(
                  child: icons.Info(
                    color: compatibility.color,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 6.0,
                bottom: 8.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${compatibility.score}%',
                    style: const TextStyle(
                      fontSize: 12.0,
                      height: 0.9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)
                        .product_page_compatibility_score,
                    style: const TextStyle(
                      fontSize: 9.0,
                      height: 0.9,
                      fontWeight: FontWeight.w500,
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
      80.0,
      (MediaQuery.sizeOf(context).width - PADDING.horizontal) * (18 / 100),
    );
  }
}

enum ProductPageBackButton {
  back,
  minimize;

  static ProductPageBackButton? byName(String? type) {
    return switch (type) {
      'back' => ProductPageBackButton.back,
      'minimize' => ProductPageBackButton.minimize,
      _ => null,
    };
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
