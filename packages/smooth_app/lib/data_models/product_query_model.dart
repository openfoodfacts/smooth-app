import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/product_list_supplier.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';

class CategoryInfo implements Comparable<CategoryInfo> {
  CategoryInfo(this.id, {required this.label, this.productCount = 0}) ;

  String id;
  String label;

  int productCount;

  @override
  int compareTo(CategoryInfo other) {
    return id.compareTo(other.id);
  }
}

class SmoothCategory extends Category<CategoryInfo> {
  SmoothCategory(CategoryInfo value) : super(value);

  @override
  String get label => value.label;

  // These overrides are just to provide more type convenience when working with the
  // categories, so we don't have to use "Category<CategoryInfo>" instead of
  // "SmoothCategory".
  @override
  Iterable<SmoothCategory> get descendants {
    return super.descendants as Iterable<SmoothCategory>;
  }

    @override
  Set<SmoothCategory> get children => super.children as Set<SmoothCategory>;

  @override
  SmoothCategory? operator [](CategoryInfo childValue) {
    return super[childValue] as SmoothCategory?;
  }
}

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

  List<String>? sortedCategories;
  SmoothCategory categories = SmoothCategory(CategoryInfo(_CATEGORY_ALL, label: 'All'));

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
