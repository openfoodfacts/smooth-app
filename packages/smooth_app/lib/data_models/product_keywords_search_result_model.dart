import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/database/full_products_database.dart';
import 'package:smooth_app/data_models/match.dart';

class ProductKeywordsSearchResultModel extends ChangeNotifier {
  ProductKeywordsSearchResultModel(this.keywords, BuildContext context) {
    _loadData(context);
    scrollController.addListener(_scrollListener);
  }

  final String keywords;
  final ScrollController scrollController = ScrollController();

  List<Product> products;
  List<Product> displayProducts;
  FullProductsDatabase productsDatabase;

  Map<String, String> categories = <String, String>{};
  Map<String, int> categoriesCounter = <String, int>{};
  List<String> sortedCategories;
  String selectedCategory = 'all';

  bool showTitle = true;

  Future<bool> _loadData(final BuildContext context) async {
    productsDatabase = FullProductsDatabase();

    products = await productsDatabase.queryProductsFromKeyword(keywords);
    final UserPreferencesModel model = UserPreferencesModel();
    await model.loadData(context);
    Match.sort(products, model);

    displayProducts = products;

    categories['all'] = 'All';

    for (final Product product in products) {
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
    print(tempCategories);

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

    notifyListeners();
    return true;
  }

  void selectCategory(String category) {
    selectedCategory = category;

    if (category == 'all') {
      displayProducts = products;
    } else {
      displayProducts = products
          .where((Product product) => product.categoriesTags.contains(category))
          .toList();
    }

    notifyListeners();
  }

  void _scrollListener() {
    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      // Reached Top
      showTitle = true;
      notifyListeners();
    } else {
      showTitle = false;
      notifyListeners();
    }
  }
}
