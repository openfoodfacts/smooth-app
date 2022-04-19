import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';

/// List of [Product]s out of partial results (e.g. paged results).
class PartialProductList {
  final List<Product> _products = <Product>[];
  int _totalSize = 0;

  /// Total size of the list from which this partial list is taken.
  int get totalSize => _totalSize;

  List<Product> getProducts() => _products;

  void add(final ProductList productList) {
    _products.addAll(productList.getList());
    _totalSize = productList.totalSize;
  }

  void clear() {
    _products.clear();
    _totalSize = 0;
  }
}
