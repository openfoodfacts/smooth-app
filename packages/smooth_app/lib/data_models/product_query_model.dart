import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
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
  ProductQueryModel(this.supplier) {
    _asyncLoad();
  }

  final ProductListSupplier supplier;

  LoadingStatus _loadingStatus = LoadingStatus.LOADING;
  String? _loadingError;
  List<Product>? _products;
  List<Product>? displayProducts;
  bool isNotEmpty() => _products != null && _products!.isNotEmpty;

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

  void process(final String translationForAll) {
    displayProducts = _products;
    _loadingStatus = LoadingStatus.COMPLETE;
  }

  void selectCategories(Set<String> categories) {
    if (categories.isEmpty) {
      displayProducts = _products;
    } else {
      displayProducts = _products!.where((Product product) {
        final Set<String> translatedCategories = product
                .categoriesTagsInLanguages?[ProductQuery.getLanguage()]
                ?.toSet() ??
            <String>{};
        return translatedCategories.intersection(categories).isNotEmpty;
      }).toList();
    }
  }
}
