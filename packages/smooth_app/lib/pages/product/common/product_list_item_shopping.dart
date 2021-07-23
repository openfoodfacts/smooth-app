import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_extra.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';

/// Widget for a [ProductList] item (shopping list)
class ProductListItemShopping extends StatelessWidget {
  ProductListItemShopping({
    required this.product,
    required this.productList,
    required this.listRefresher,
    required this.daoProductList,
    required this.reorderIndex,
    Key? key,
  })  : _productExtra = productList.getProductExtra(product.barcode!),
        super(key: key);

  final Product product;
  final ProductList productList;
  final VoidCallback listRefresher;
  final DaoProductList daoProductList;
  final int reorderIndex;
  final ProductExtra _productExtra;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ProductListItemSimple(
        product: product,
        productList: productList,
        listRefresher: listRefresher,
        daoProductList: daoProductList,
        reorderIndex: reorderIndex,
      ),
      const Divider(color: Colors.grey),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () async => _add(-1),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('${_getCount()}', style: const TextStyle(fontSize: 16)),
          IconButton(
            onPressed: () async => _add(1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    ]);
  }

  /// Returns the count of the product from the [ProductExtra] string value
  ///
  /// Very strategic method
  int _getCount() => int.parse(
      _productExtra.stringValue == ProductList.PRODUCT_EXTRA_INIT_STRING_VALUE
          ? _PRODUCT_EXTRA_INIT_STRING_VALUE
          : _productExtra.stringValue);

  /// Actual default value for shopping lists
  ///
  /// Instead of [ProductList.PRODUCT_EXTRA_INIT_STRING_VALUE]
  /// This value means: count=1
  static const String _PRODUCT_EXTRA_INIT_STRING_VALUE = '1';

  /// Sets the count of the product to a [productExtra] string value
  ///
  /// Very strategic method
  /// Returns true if successful
  bool _setCount(final ProductExtra productExtra, final int count) {
    if (count > 0) {
      productExtra.stringValue = '$count';
      return true;
    }
    return false;
  }

  Future<void> _add(final int increment) async {
    final int count = _getCount() + increment;
    if (_setCount(_productExtra, count)) {
      productList.setProductExtra(product.barcode!, _productExtra);
    } else {
      productList.remove(product.barcode!);
    }
    await daoProductList.put(
        productList); // TODO(monsieurtanuki): save just the extra, not the whole product list
    listRefresher();
  }
}
