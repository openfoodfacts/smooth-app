import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/attribute_chip.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/product/product_page.dart';

class ProductCard extends StatelessWidget {
  const ProductCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final String title =
        product.productName ?? product.brands ?? product.barcode ?? 'Unknown';
    final String subtitle =
        product.productName == null ? '' : (product.brands ?? '');
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18.0),
            ),
            Expanded(child: _buildScores(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildScores(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final List<String> attributeIds =
        productPreferences.getOrderedImportantAttributeIds();
    final List<Attribute> attributes =
        AttributeListExpandable.getPopulatedAttributes(product, attributeIds);
    return Row(
      children: attributes
          .map((Attribute attr) => Flexible(
                child: AttributeChip(attr),
              ))
          .toList(),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    await Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => ProductPage(product: product),
      ),
    );
  }
}
