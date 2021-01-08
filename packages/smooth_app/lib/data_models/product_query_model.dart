import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/data_models/match.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/temp/user_preferences.dart';

enum LoadingStatus {
  LOADING,
  LOADED,
  POST_LOAD_STARTED,
  COMPLETE,
  ERROR,
}

class ProductQueryModel with ChangeNotifier {
  ProductQueryModel(final ProductQuery productQuery) {
    _asyncLoad(productQuery);
  }

  static const String _CATEGORY_ALL = 'all';

  LoadingStatus _loadingStatus = LoadingStatus.LOADING;
  String _loadingError;
  List<Product> _products;
  List<Product> displayProducts;
  bool isNotEmpty() => _products != null && _products.isNotEmpty;

  Map<String, String> categories = <String, String>{};
  Map<String, int> categoriesCounter = <String, int>{};
  List<String> sortedCategories;

  String get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  Future<void> _asyncLoad(final ProductQuery productQuery) async {
    try {
      final SearchResult searchResult = await productQuery.getSearchResult();
      _products = searchResult.products;
      _loadingStatus = LoadingStatus.LOADED;
    } catch (e) {
      _loadingStatus = LoadingStatus.ERROR;
      _loadingError = e.toString();
    }
    notifyListeners();
  }

  void sort(
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
    final LocalDatabase localDatabase,
  ) {
    if (_loadingStatus != LoadingStatus.LOADED) {
      return;
    }
    _loadingStatus = LoadingStatus.POST_LOAD_STARTED;

    localDatabase.putProducts(_products);
    Match.sort(_products, userPreferences, userPreferencesModel);

    displayProducts = _products;

    categories[_CATEGORY_ALL] =
        'All'; // TODO(monsieurtanuki): find a translation

    for (final Product product in _products) {
      for (final String category in product.categoriesTags) {
        categories.putIfAbsent(category, () {
          String title = category.substring(3).replaceAll('-', ' ');
          title = '${title[0].toUpperCase()}${title.substring(1)}';
          return title;
        });
        categoriesCounter[category] = (categoriesCounter[category] ?? 0) + 1;
      }
    }

    final List<String> tempCategories = categories.keys.toList();

    for (final String category in tempCategories) {
      if (category != _CATEGORY_ALL) {
        if (categoriesCounter[category] <= 1) {
          categories.remove(category);
        } else {
          categories[category] =
              '${categories[category]} (${categoriesCounter[category]})';
        }
      }
    }

    sortedCategories = categories.keys.toList();
    sortedCategories.sort((String a, String b) {
      if (a == _CATEGORY_ALL) {
        return -1;
      } else if (b == _CATEGORY_ALL) {
        return 1;
      }
      return categoriesCounter[b].compareTo(categoriesCounter[a]);
    });

    _loadingStatus = LoadingStatus.COMPLETE;
  }

  void selectCategory(String category) {
    if (category == _CATEGORY_ALL) {
      displayProducts = _products;
    } else {
      displayProducts = _products
          .where((Product product) => product.categoriesTags.contains(category))
          .toList();
    }
  }
}
