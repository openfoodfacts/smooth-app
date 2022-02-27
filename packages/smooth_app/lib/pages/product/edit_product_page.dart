import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';

/// Page where we can indirectly edit all data about a product.
class EditProductPage extends StatelessWidget {
  const EditProductPage(this.product);

  final Product product;

  // TODO(monsieurtanuki): translations

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.productName!)),
      body: ListView(
        children: <ListTile>[
          ListTile(
            title: const Text('Basic details'),
            subtitle: const Text('Product name, brand, quantity'),
            leading: _getLeadingWidget(),
          ),
          ListTile(
            title: const Text('Photos'),
            subtitle: const Text('Add or refresh photos'),
            leading: _getLeadingWidget(),
          ),
          ListTile(
            title: const Text('Labels & Certifications'),
            subtitle: const Text('Environmental, Quality labels, ...'),
            leading: _getLeadingWidget(),
          ),
          ListTile(
            title: const Text('Ingredients & Origins'),
            leading: _getLeadingWidget(),
          ),
          ListTile(
            title: const Text('Packaging'),
            leading: _getLeadingWidget(),
          ),
          ListTile(
            title: const Text('Nutrition facts'),
            subtitle: const Text('Nutrition, alcohol content, ...'),
            leading: _getLeadingWidget(),
          ),
        ],
      ),
    );
  }

  Widget _getLeadingWidget() => ElevatedButton(
        child: const Text('Edit'),
        onPressed: () {},
      );
}
