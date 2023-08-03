import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/hideable_container.dart';
import 'package:smooth_app/pages/product/summary_card.dart';

class ScanProductCard extends StatelessWidget {
  ScanProductCard(this.product)
      : assert(product.barcode!.isNotEmpty),
        super(key: Key(product.barcode!));

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
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
      child: Hero(
        tag: product.barcode ?? '',
        child: HideableContainer(
          child: SummaryCard(
            product,
            productPreferences,
            attributeGroupsClickable: false,
            padding: const EdgeInsets.symmetric(
              vertical: VERY_SMALL_SPACE,
            ),
          ),
        ),
      ),
    );
  }

  void _openProductPage(BuildContext context) {
    AppNavigator.of(context).push(
      AppRoutes.PRODUCT(product.barcode!),
      extra: product,
    );
  }
}
