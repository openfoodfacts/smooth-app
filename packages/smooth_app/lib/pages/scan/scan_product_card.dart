import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';
import 'package:smooth_app/pages/product/summary_card.dart';

class ScanProductCard extends StatelessWidget {
  const ScanProductCard(this.product);

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
        child: SummaryCard(product, productPreferences),
      ),
    );
  }

  Future<void> _openProductPage(BuildContext context) async {
    await Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => ProductPage(product),
      ),
    );
  }
}
