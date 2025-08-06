import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/product_page/new_product_header.dart';
import 'package:smooth_app/pages/product/summary_card.dart';

class ScanProductCardFound extends StatelessWidget {
  ScanProductCardFound({required this.product, required this.onRemoveProduct})
    : assert(product.barcode!.isNotEmpty),
      super(key: Key(product.barcode!));

  final Product product;
  final OnRemoveCallback? onRemoveProduct;

  @override
  Widget build(BuildContext context) {
    final ProductCompatibilityHelper helper =
        ProductCompatibilityHelper.product(
          MatchedProductV2(product, context.watch<ProductPreferences>()),
        );

    final ProductPreferences productPreferences = context
        .watch<ProductPreferences>();
    final String? compatibilityScore = helper.getFormattedScore();

    return GestureDetector(
      onTap: () => _openProductPage(context),
      onVerticalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity == null) {
          return;
        }
        if (details.primaryVelocity! < 0) {
          _openProductPage(context);
        }
      },
      child: ScanProductBaseCard(
        headerLabel: compatibilityScore != null
            ? '${helper.getSubtitle(AppLocalizations.of(context))} ($compatibilityScore%)'
            : product.barcode!,
        headerIndicatorColor: Colors.white,
        headerBackgroundColor: helper.getColor(context),
        childPadding: EdgeInsets.zero,
        onRemove: onRemoveProduct,
        child: SummaryCard(
          product,
          productPreferences,
          heroTag: _heroTag,
          attributeGroupsClickable: false,
          margin: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: VERY_SMALL_SPACE,
          ),
          scrollableContent: true,
          isTextSelectable: false,
        ),
      ),
    );
  }

  String get _heroTag =>
      ProductPicture.generateHeroTag(product.barcode!, ImageField.FRONT);

  void _openProductPage(BuildContext context) {
    AppNavigator.of(context).push(
      AppRoutes.PRODUCT(
        product.barcode!,
        heroTag: _heroTag,
        backButtonType: ProductPageBackButton.minimize,
        transition: ProductPageTransition.slideUp,
      ),
      extra: product,
    );
  }
}
