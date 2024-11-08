import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_product_image.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';

class SmoothProductCardFound extends StatelessWidget {
  const SmoothProductCardFound({
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
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Size screenSize = MediaQuery.sizeOf(context);
    final ThemeData themeData = Theme.of(context);
    final bool isDarkMode = themeData.colorScheme.brightness == Brightness.dark;
    final List<String> excludedAttributeIds =
        userPreferences.getExcludedAttributeIds();
    final List<Widget> scores = <Widget>[];
    final double iconSize = IconWidgetSizer.getIconSizeFromContext(context);
    final List<Attribute> attributes = getPopulatedAttributes(
      product,
      SCORE_ATTRIBUTE_IDS,
      excludedAttributeIds,
    );
    for (final Attribute attribute in attributes) {
      scores.add(SvgIconChip(attribute.iconUrl!, height: iconSize));
    }
    final MatchedProductV2 matchedProduct = MatchedProductV2(
      product,
      productPreferences,
    );
    final ProductCompatibilityHelper helper =
        ProductCompatibilityHelper.product(matchedProduct);
    final Widget child = InkWell(
      borderRadius: ROUNDED_BORDER_RADIUS,
      onTap: onTap ??
          () => AppNavigator.of(context).push(
                AppRoutes.PRODUCT(
                  product.barcode!,
                  heroTag: heroTag,
                ),
                extra: product,
              ),
      onLongPress: () => onLongPress?.call(),
      child: Hero(
        tag: heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: ROUNDED_BORDER_RADIUS,
              color:
                  backgroundColor ?? (isDarkMode ? Colors.black : Colors.white),
            ),
            child: SmoothCard(
              elevation: elevation,
              color: Colors.transparent,
              padding: const EdgeInsets.all(VERY_SMALL_SPACE),
              child: Row(
                children: <Widget>[
                  SmoothMainProductImage(
                    product: product,
                    width: screenSize.width * 0.20,
                    height: screenSize.width * 0.20,
                  ),
                  const Padding(
                    padding:
                        EdgeInsetsDirectional.only(start: VERY_SMALL_SPACE),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: screenSize.width * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            getProductName(product, appLocalizations),
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.headlineMedium,
                          ),
                          Text(
                            getProductBrands(product, appLocalizations),
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.titleMedium,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.circle,
                                size: 15,
                                color: helper.getColor(context),
                              ),
                              const Padding(
                                padding: EdgeInsetsDirectional.only(
                                    start: VERY_SMALL_SPACE),
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    helper.getSubtitle(appLocalizations),
                                    style: themeData.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsetsDirectional.only(start: VERY_SMALL_SPACE),
                  ),
                  if (scores.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(VERY_SMALL_SPACE),
                      child: Column(
                        children: scores,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // TODO(monsieurtanuki): check localDatabase.upToDate.hasPendingChanges and display a "pending changes" mark if relevant
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MEDIUM_SPACE,
        vertical: SMALL_SPACE,
      ),
      child: child,
    );
  }
}
