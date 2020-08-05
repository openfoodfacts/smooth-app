
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:smooth_app/database/full_products_database.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';

class ProductGroupQueryModel extends ChangeNotifier {

  ProductGroupQueryModel(this.group) {
    _loadData();
    scrollController.addListener(_scrollListener);
  }

  final PnnsGroup2 group;
  final ScrollController scrollController = ScrollController();

  List<Product> products;
  List<Product> displayProducts;
  FullProductsDatabase productsDatabase;

  Map<String, String> categories = <String, String>{};
  List<String> sortedCategories;
  String selectedCategory = 'all';

  bool showTitle = true;

  Future<bool> _loadData() async {
    productsDatabase = FullProductsDatabase();

    products = await productsDatabase.queryProductsFromKeyword(group.id);

    products.sort((Product p1, Product p2) {
      final int p1Score = FilterRankingHelper.nutriScorePoints(p1) + FilterRankingHelper.novaGroupPoints(p1);
      final int p2Score = FilterRankingHelper.nutriScorePoints(p2) + FilterRankingHelper.novaGroupPoints(p2);

      return p2Score.compareTo(p1Score);
    });

    displayProducts = products;

    categories['all'] = 'All';

    for(final Product product in products) {
      for(final String category in product.categoriesTags) {
        categories.putIfAbsent(category, () {
          String title = category.substring(3).replaceAll('-', ' ');
          title = '${title[0].toUpperCase()}${title.substring(1)}';
          return title;
        });
      }
    }

    sortedCategories = categories.keys.toList();
    sortedCategories.sort();

    notifyListeners();
    return true;
  }


  void selectCategory(String category) {
    selectedCategory = category;

    if(category == 'all') {
      displayProducts = products;
    } else {
      displayProducts = products.where((Product product) => product.categoriesTags.contains(category)).toList();
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