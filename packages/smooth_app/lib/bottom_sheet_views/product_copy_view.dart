import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list.dart';

///The ModalBottomSheet to choose where to copy/add products to
class ProductCopyView extends StatelessWidget {
  const ProductCopyView(this.children);

  final Map<String, List<Widget>> children;

  static const List<String> _USER_PRODUCT_TYPES = <String>[
    ProductList.LIST_TYPE_USER_DEFINED,
    ProductList.LIST_TYPE_USER_PANTRY,
    ProductList.LIST_TYPE_USER_SHOPPING,
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    items.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
        child: Text(
          'Add this product',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
    for (final String productListType in _USER_PRODUCT_TYPES) {
      items.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            _getLabel(productListType),
            style: Theme.of(context).textTheme.headline2,
          ),
          width: MediaQuery.of(context).size.width,
        ),
      );
      items.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Wrap(
            direction: Axis.horizontal,
            children: children[productListType]!,
            spacing: 8.0,
          ),
        ),
      );
    }
    items.add(
      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
    );
    return Material(
      child: Container(
        child: ListView(
            shrinkWrap: true, scrollDirection: Axis.vertical, children: items),
      ),
    );
  }

  String _getLabel(final String productListType) {
    switch (productListType) {
      case ProductList.LIST_TYPE_USER_DEFINED:
        return 'Lists:';
      case ProductList.LIST_TYPE_USER_PANTRY:
        return 'Pantries:';
      case ProductList.LIST_TYPE_USER_SHOPPING:
        return 'Shopping lists:';
    }
    throw Exception('product list type $productListType not handled');
  }
}
