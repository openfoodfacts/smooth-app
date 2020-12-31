import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/data_models/match.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class ProductQueryModel {
  ProductQueryModel();

  List<Product> _products;
  List<Product> displayProducts;
  bool isNotEmpty() => _products != null && _products.isNotEmpty;

  Map<String, String> categories = <String, String>{};
  Map<String, int> categoriesCounter = <String, int>{};
  List<String> sortedCategories;
  String selectedCategory = 'all';

  Future<bool> loadData(
    final ProductQuery productQuery,
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
  ) async {
    if (_products != null) {
      return true;
    }

    _products = await productQuery.queryProducts();
    Match.sort(_products, userPreferences, userPreferencesModel);

    displayProducts = _products;

    categories['all'] = 'All';

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
      if (category != 'all') {
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
      if (a == 'all') {
        return -1;
      } else if (b == 'all') {
        return 1;
      }
      return categoriesCounter[b].compareTo(categoriesCounter[a]);
    });

    return true;
  }

  void selectCategory(String category) {
    selectedCategory = category;

    if (category == 'all') {
      displayProducts = _products;
    } else {
      displayProducts = _products
          .where((Product product) => product.categoriesTags.contains(category))
          .toList();
    }
  }
}
