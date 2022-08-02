import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/query/product_query.dart';

enum LoadingStatus {
  LOADING,
  LOADED,
  ERROR,
}

class ProductQueryModel with ChangeNotifier {
  ProductQueryModel(this._supplier, this._daoProduct) {
    _clear();
    _asyncLoad(notify: true);
  }

  ProductListSupplier _supplier;
  final DaoProduct _daoProduct;

  ProductListSupplier get supplier => _supplier;

  static const String _CATEGORY_ALL = 'all';
  late String currentCategory;

  late LoadingStatus _loadingStatus;
  String? _loadingError;
  final List<String> _barcodes = <String>[];
  List<String>? displayBarcodes;
  bool isNotEmpty() => _barcodes.isNotEmpty;
  final Map<String, List<String>> _productCategories = <String, List<String>>{};

  /// <Label, Label (count)> [Map]
  final Map<String, String> categories = <String, String>{};

  /// <Label, count> [Map]
  final Map<String, int> _categoriesCounter = <String, int>{};

  /// Sorted labels
  final List<String> sortedCategories = <String>[];

  String? get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  /// Sets the translation for meta category "All".
  void setTranslationForAll(final String translationForAll) =>
      categories[_CATEGORY_ALL] = translationForAll;

  void _clear() {
    currentCategory = _CATEGORY_ALL;
    _loadingStatus = LoadingStatus.LOADING;
    _loadingError = null;
    _barcodes.clear();
    displayBarcodes = null;
    _productCategories.clear();
    categories.clear();
    _categoriesCounter.clear();
    sortedCategories.clear();
  }

  Future<bool> _asyncLoad({final bool notify = false}) async {
    _loadingError = await supplier.asyncLoad();
    if (_loadingError != null) {
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      await _process(supplier.partialProductList.getBarcodes());
      _loadingStatus = LoadingStatus.LOADED;
    }
    if (notify) {
      notifyListeners();
    }
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
  /// Is a bit long because we need to get each product from the database,
  /// in order to know before display all the available categories.
  /// Optim 1: dismiss this filter altogether.
  /// Optim 2: get several products at a time - how faster would that be?
  /// Optim 3: compute the filter async.
  Future<void> _process(final List<String> barcodes) async {
    _barcodes.addAll(barcodes);
    displayBarcodes = _barcodes;

    categories[_CATEGORY_ALL] = ''; // to be overridden later
    for (final String barcode in barcodes) {
      final Product? product = await _daoProduct.get(barcode);
      if (product == null) {
        // unexpected
        continue;
      }
      if (product.categoriesTagsInLanguages != null) {
        final List<String>? translatedCategories =
            product.categoriesTagsInLanguages![ProductQuery.getLanguage()];
        if (translatedCategories != null) {
          _productCategories[product.barcode!] = translatedCategories;
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

    _loadingStatus = LoadingStatus.LOADED;
  }

  void selectCategory(String category) {
    currentCategory = category;
    if (category == _CATEGORY_ALL) {
      displayBarcodes = _barcodes;
    } else {
      final List<String> result = <String>[];
      _productCategories.forEach(
        (final String barcode, final List<String> categories) {
          if (categories.contains(category)) {
            result.add(barcode);
          }
        },
      );
      displayBarcodes = result;
    }
  }
}
