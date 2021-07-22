import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';

enum LoadingStatus {
  LOADING,
  LOADED,
  POST_LOAD_STARTED,
  COMPLETE,
  ERROR,
}

class ProductQueryModel with ChangeNotifier {
  ProductQueryModel(this.supplier) {
    _asyncLoad();
  }

  final ProductListSupplier supplier;

  static const String _CATEGORY_ALL = 'all';

  LoadingStatus _loadingStatus = LoadingStatus.LOADING;
  String? _loadingError;
  List<Product>? _products;
  List<Product>? displayProducts;
  bool isNotEmpty() => _products != null && _products!.isNotEmpty;

  Map<String, String> categories = <String, String>{};
  Map<String, int> categoriesCounter = <String, int>{};
  List<String>? sortedCategories;

  String? get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  Future<void> _asyncLoad() async {
    _loadingError = await supplier.asyncLoad();
    if (_loadingError != null) {
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      _loadingStatus = LoadingStatus.LOADED;
      _products = supplier.getProductList().getList();
    }
    notifyListeners();
  }

  void process() {
    if (_loadingStatus != LoadingStatus.LOADED) {
      return;
    }
    _loadingStatus = LoadingStatus.POST_LOAD_STARTED;

    final ProductList productList = supplier.getProductList();
    _products = productList.getList();

    displayProducts = _products;

    categories[_CATEGORY_ALL] =
        'All'; // TODO(monsieurtanuki): find a translation

    for (final Product product in _products!) {
      if (product.categoriesTags != null) {
        for (final String category in product.categoriesTags!) {
          categories.putIfAbsent(category, () {
            String title = category.substring(3).replaceAll('-', ' ');
            title = '${title[0].toUpperCase()}${title.substring(1)}';
            return title;
          });
          categoriesCounter[category] = (categoriesCounter[category] ?? 0) + 1;
        }
      }
    }

    final List<String> tempCategories = categories.keys.toList();

    for (final String category in tempCategories) {
      if (category != _CATEGORY_ALL) {
        if (categoriesCounter[category]! <= 1) {
          categories.remove(category);
        } else {
          categories[category] =
              '${categories[category]} (${categoriesCounter[category]})';
        }
      }
    }

    sortedCategories = categories.keys.toList();
    sortedCategories!.sort((String a, String b) {
      if (a == _CATEGORY_ALL) {
        return -1;
      } else if (b == _CATEGORY_ALL) {
        return 1;
      }
      return categoriesCounter[b]!.compareTo(categoriesCounter[a]!);
    });

    _loadingStatus = LoadingStatus.COMPLETE;
  }

  void selectCategory(String category) {
    if (category == _CATEGORY_ALL) {
      displayProducts = _products;
    } else {
      displayProducts = _products!
          .where((Product product) =>
              product.categoriesTags?.contains(category) ?? false)
          .toList();
    }
  }
}
