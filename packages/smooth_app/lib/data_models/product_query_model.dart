import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_app/data_models/smooth_category.dart';
import 'package:smooth_app/database/category_query.dart';
import 'package:smooth_app/database/product_query.dart';

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

  LoadingStatus _loadingStatus = LoadingStatus.LOADING;
  final CategoryQuery _categoryQuery = CategoryQuery();
  String? _loadingError;
  List<Product>? _products;
  List<Product>? displayProducts;
  bool isNotEmpty() => _products != null && _products!.isNotEmpty;

  /// The currently selected filter categories.
  Set<Category> selectedCategories = <Category>{};
  /// The currently selected category path.
  List<Category> categoryPath = <Category>[];

  Future<CategoryTreeNode?> getCategory(Iterable<Category> categoryPath) async {
    debugPrint('Getting category for path $categoryPath');
    if (categoryPath.isEmpty) {
      debugPrint('Getting root category');
      return _categoryQuery.getCategoryTreeRoot();
    }
    debugPrint('Getting category ${categoryPath.last.tag}');
    return _categoryQuery.getCategory(categoryPath.last.tag);
  }

  void setCategoryPath(Iterable<Category> value) {
    categoryPath = value.toList();
    notifyListeners();
  }

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

  /// Sorts the products by category.
  void process(final String translationForAll) {
    if (_loadingStatus != LoadingStatus.LOADED) {
      return;
    }
    _loadingStatus = LoadingStatus.POST_LOAD_STARTED;

    final ProductList productList = supplier.getProductList();
    _products = productList.getList();

    displayProducts = _products;
    _loadingStatus = LoadingStatus.COMPLETE;
  }

  void selectCategories(Set<Category> categories) {
    if (categories.isEmpty) {
      displayProducts = _products;
    } else {
      selectedCategories = categories;
      final Set<String> categoryNames = categories.map<String>(
        (Category category) => category.getName(ProductQuery.getLanguage()!),
      ).toSet();
      displayProducts = _products!
          .where((Product product) =>
              product.categoriesTagsInLanguages?[ProductQuery.getLanguage()]
                  ?.toSet()
                  .intersection(categoryNames)
                  .isNotEmpty ??
              false)
          .toList();
    }
  }
}
