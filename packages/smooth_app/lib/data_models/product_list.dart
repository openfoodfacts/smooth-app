import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';

class ProductList {
  ProductList({
    @required this.listType,
    @required this.parameters,
  });

  final String listType;
  final String parameters;

  final List<String> _barcodes = <String>[];
  final Map<String, Product> _products = <String, Product>{};

  static const String LIST_TYPE_HTTP_SEARCH_GROUP = 'http/search/group';
  static const String LIST_TYPE_HTTP_SEARCH_KEYWORDS = 'http/search/keywords';

  List<String> get barcodes => _barcodes;

  bool isEmpty() => _barcodes.isEmpty;

  void clear() {
    _barcodes.clear();
    _products.clear();
  }

  void add(final Product product) {
    if (product == null) {
      throw Exception('null product');
    }
    final String barcode = product.barcode;
    if (barcode == null) {
      throw Exception('null barcode');
    }
    _barcodes.add(barcode);
    _products[barcode] = product;
  }

  void addAll(final List<Product> products) => products.forEach(add);

  void set(
    final List<String> barcodes,
    final Map<String, Product> products,
  ) {
    clear();
    _barcodes.addAll(barcodes);
    _products.addAll(products);
  }

  List<Product> getList() {
    final List<Product> result = <Product>[];
    for (final String barcode in _barcodes) {
      final Product product = _products[barcode];
      if (product == null) {
        throw Exception('no product for barcode $barcode');
      }
      result.add(product);
    }
    return result;
  }
}
