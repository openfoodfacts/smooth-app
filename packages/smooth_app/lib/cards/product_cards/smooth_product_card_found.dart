import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothProductCardItemFound extends StatelessWidget {
  const SmoothProductCardItemFound({
    required this.product,
    required this.heroTag,
    this.backgroundColor,
    this.onLongPress,
    this.onTap,
  });

  final Product product;
  final String heroTag;
  static const double elevation = 4.0;
  final Color? backgroundColor;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);

    Widget child = Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: LARGE_SPACE,
        vertical: LARGE_SPACE,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              const _SmoothProductItemPicture(),
              const SizedBox(width: BALANCED_SPACE),
              Expanded(
                child: SizedBox(
                  height: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              themeData.textTheme.headlineMedium!.fontSize! *
                                  2.0,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            getProductName(product, appLocalizations),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: VERY_SMALL_SPACE),
                      Text(
                        getProductBrands(product, appLocalizations),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: themeData.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      const _SmoothProductItemScores()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (product.productType != ProductType.food) {
      child = Stack(
        children: <Widget>[
          const PositionedDirectional(
            bottom: 0.0,
            end: 0.0,
            child: _SmoothProductItemTypeIndicator(),
          ),
          child,
        ],
      );
    }

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<Product>(
          create: (_) => product,
        ),
        Provider<String>.value(value: heroTag),
      ],
      child: InkWell(
        onTap: onTap ??
            () => AppNavigator.of(context).push(
                  AppRoutes.PRODUCT(
                    product.barcode!,
                    heroTag: heroTag,
                  ),
                  extra: product,
                ),
        onLongPress: () => onLongPress?.call(),
        child: child,
      ),
    );
  }
}

class _SmoothProductItemPicture extends StatelessWidget {
  const _SmoothProductItemPicture();

  @override
  Widget build(BuildContext context) {
    final Product product = context.watch<Product>();
    final double size = MediaQuery.sizeOf(context).width * 0.25;
    final bool hasScore = product.productType == ProductType.food;
    final Color borderColor;
    final Widget? scoreWidget;

    if (hasScore) {
      final ProductPreferences productPreferences =
          context.watch<ProductPreferences>();

      final MatchedProductV2 matchedProduct = MatchedProductV2(
        product,
        productPreferences,
      );
      final ProductCompatibilityHelper helper =
          ProductCompatibilityHelper.product(matchedProduct);
      final String? score = helper.getFormattedScore(singleDigitAllowed: true);

      borderColor = helper.getColor(context);

      scoreWidget = SizedBox(
        width: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: helper.getColor(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(08.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: SMALL_SPACE,
              end: SMALL_SPACE,
              top: 6.0,
              bottom: 8.0,
            ),
            child: Text(
              score != null
                  ? '$score%'
                  : AppLocalizations.of(context).not_applicable_short,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      scoreWidget = null;
      borderColor = context.extension<SmoothColorsThemeExtension>().greyNormal;
    }

    return Ink(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(09.0),
        ),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        children: <Widget>[
          if (scoreWidget != null) scoreWidget,
          ProductPicture.fromProduct(
            product: product,
            imageField: ImageField.FRONT,
            size: Size(size, size - (scoreWidget != null ? 25.0 : 5.0)),
            borderRadius: BorderRadius.vertical(
              top: hasScore ? Radius.zero : const Radius.circular(08.0),
              bottom: const Radius.circular(08.0),
            ),
            noImageBuilder: (_) => const PictureNotFound(),
            heroTag: context.watch<String>(),
            blurFilter: false,
          ),
        ],
      ),
    );
  }
}

class _SmoothProductItemScores extends StatelessWidget {
  const _SmoothProductItemScores();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: VERY_SMALL_SPACE,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: BALANCED_SPACE,
        children: _getWidgets(context),
      ),
    );
  }

  List<Widget> _getWidgets(BuildContext context) {
    final Product product = context.watch<Product>();

    final UserPreferences userPreferences = context.watch<UserPreferences>();

    final List<String> excludedAttributeIds =
        userPreferences.getExcludedAttributeIds();

    final List<Attribute> attributes = getPopulatedAttributes(
      product,
      SCORE_ATTRIBUTE_IDS,
      excludedAttributeIds,
    );

    final List<Widget> scores = List<Widget>.generate(
      attributes.length,
      (int index) {
        final bool nutriScoreLogo = attributes[index]
                .iconUrl
                ?.contains(RegExp(r'.*/nutriscore-[a-z]-.*\.svg')) ==
            true;

        Widget child = SvgIconChip(
          attributes[index].iconUrl!,
          height: 39.0 - (nutriScoreLogo ? 1.0 : 0.0),
        );

        if (nutriScoreLogo) {
          child = DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: context.lightTheme() ? Colors.black26 : Colors.white54,
                width: 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(6.5),
              ),
            ),
            child: child,
          );
        }

        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 1.0),
          child: child,
        );
      },
    );
    return scores;
  }
}

class _SmoothProductItemTypeIndicator extends StatelessWidget {
  const _SmoothProductItemTypeIndicator();

  @override
  Widget build(BuildContext context) {
    final ProductType? productType = context.watch<Product>().productType;

    if (productType == null) {
      return EMPTY_WIDGET;
    }

    return SvgPicture.asset(
      productType.getIllustration(),
      width: 50.0,
    );
  }
}
