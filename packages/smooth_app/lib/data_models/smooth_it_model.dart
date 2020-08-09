
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/user_database.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class SmoothItModel extends ChangeNotifier {

  SmoothItModel(this.unprocessedProducts) {
    _loadData();
    scrollController.addListener(_scrollListener);
  }

  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _loadData() async {
    try {
      dataLoaded = await processProductList();
      notifyListeners();
      return true;
    } catch(e) {
      print('An error occurred while processing the product list : $e');
      dataLoaded = false;
      return false;
    }
  }

  List<Product> unprocessedProducts;
  List<RankedProduct> products;

  List<RankedProduct> topPicks;
  List<RankedProduct> contenders;
  List<RankedProduct> dismissed;

  UserPreferences userPreferences;
  bool dataLoaded = false;

  bool showTitle = true;

  Future<bool> processProductList() async {
    try {
      userPreferences = await UserDatabase().getUserPreferences();
      products = FilterRankingHelper.process(unprocessedProducts, userPreferences);
      topPicks = products.where((RankedProduct rankedProduct) => rankedProduct.type == RankingType.TOP_PICKS).toList();
      contenders = products.where((RankedProduct rankedProduct) => rankedProduct.type == RankingType.CONTENDERS).toList();
      dismissed = products.where((RankedProduct rankedProduct) => rankedProduct.type == RankingType.DISMISSED).toList();
      notifyListeners();
      return true;
    } catch(e) {
      print(e);
      return false;
    }

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