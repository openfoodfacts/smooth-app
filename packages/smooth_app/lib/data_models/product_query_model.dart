import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/database/product_query.dart';

enum LoadingStatus {
  LOADING,
  LOADED,
  POST_LOAD_STARTED,
  COMPLETE,
  ERROR,
}

class ProductQueryModel with ChangeNotifier {
  ProductQueryModel(this._supplier) {
    _clear();
    _asyncLoad();
  }

  ProductListSupplier _supplier;

  ProductListSupplier get supplier => _supplier;

  static const String _CATEGORY_ALL = 'all';
  late String currentCategory;

  late LoadingStatus _loadingStatus;
  String? _loadingError;
  final List<Product> _products = <Product>[];
  List<Product>? displayProducts;
  bool isNotEmpty() => _products.isNotEmpty;

  /// <Label, Label (count)> [Map]
  final Map<String, String> categories = <String, String>{};

  /// <Label, count> [Map]
  final Map<String, int> _categoriesCounter = <String, int>{};

  /// Sorted labels
  final List<String> sortedCategories = <String>[];

  String? get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  void _clear() {
    currentCategory = _CATEGORY_ALL;
    _loadingStatus = LoadingStatus.LOADING;
    _loadingError = null;
    _products.clear();
    displayProducts = null;
    categories.clear();
    _categoriesCounter.clear();
    sortedCategories.clear();
  }

  Future<bool> _asyncLoad() async {
    _loadingError = await supplier.asyncLoad();
    if (_loadingError != null) {
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      _loadingStatus = LoadingStatus.LOADED;
      _products.addAll(supplier.partialProductList.getProducts());
    }
    notifyListeners();
    return _loadingStatus == LoadingStatus.LOADED;
  }

  Future<bool> loadNextPage() async {
    final ProductListSupplier? refreshSupplier = supplier.getRefreshSupplier();
    if (refreshSupplier != null) {
      // in that case, we were on a database supplier, on an empty page
      _supplier = refreshSupplier;
    } else {
      // in that case, we were on a back-end supplier, on a loaded page
      supplier.productQuery.toNextPage();
    }
    return _asyncLoad();
  }

  // TODO(monsieurtanuki): don't clear everything if it fails?
  Future<bool> loadFromTop() async {
    _clear();

    final ProductListSupplier? refreshSupplier = supplier.getRefreshSupplier();
    if (refreshSupplier != null) {
      // in that case, we were on a database supplier
      _supplier = refreshSupplier;
    } else {
      // in that case, we were already on a back-end supplier
    }
    await supplier.clear();
    supplier.productQuery.toTopPage();
    return _asyncLoad();
  }

  /// Sorts the products by category.
  ///
  /// [translationForAll] is the displayed translation for meta category "All".
  void process(final String translationForAll) {
    if (_loadingStatus != LoadingStatus.LOADED) {
      return;
    }
    _loadingStatus = LoadingStatus.POST_LOAD_STARTED;

    displayProducts = _products;

    categories[_CATEGORY_ALL] = translationForAll;

    for (final Product product in _products) {
      if (product.categoriesTagsInLanguages != null) {
        final List<String>? translatedCategories =
            product.categoriesTagsInLanguages![ProductQuery.getLanguage()];
        if (translatedCategories != null) {
          for (final String category in translatedCategories) {
            categories[category] = '';
            _categoriesCounter[category] =
                (_categoriesCounter[category] ?? 0) + 1;
          }
        }
      }
    }

    final List<String> tempCategories = categories.keys.toList();

    for (final String category in tempCategories) {
      if (category != _CATEGORY_ALL) {
        if (_categoriesCounter[category]! <= 1) {
          categories.remove(category);
        } else {
          categories[category] = '$category (${_categoriesCounter[category]})';
        }
      }
    }

    sortedCategories.clear();
    sortedCategories.addAll(categories.keys);
    sortedCategories.sort((String a, String b) {
      if (a == _CATEGORY_ALL) {
        return -1;
      } else if (b == _CATEGORY_ALL) {
        return 1;
      }
      return _categoriesCounter[b]!.compareTo(_categoriesCounter[a]!);
    });

    _loadingStatus = LoadingStatus.COMPLETE;
  }

  void selectCategory(String category) {
    currentCategory = category;
    if (category == _CATEGORY_ALL) {
      displayProducts = _products;
    } else {
      displayProducts = _products
          .where((Product product) =>
              product.categoriesTagsInLanguages?[ProductQuery.getLanguage()]
                  ?.contains(category) ??
              false)
          .toList();
    }
  }
}
