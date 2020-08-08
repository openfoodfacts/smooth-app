
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/user_database.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class SmoothItModel extends ChangeNotifier {

  SmoothItModel(List<Product> input) {
    _loadData(input);
    scrollController.addListener(_scrollListener);
  }

  final ScrollController scrollController = ScrollController();

  Future<bool> _loadData(List<Product> input) async {
    try {
      userPreferences = await UserDatabase().getUserPreferences();
      dataLoaded = true;
      products = FilterRankingHelper.process(input, userPreferences);
      notifyListeners();
      return true;
    } catch(e) {
      print('An error occurred while loading user preferences : $e');
      dataLoaded = false;
      return false;
    }
  }

  List<RankedProduct> products;
  UserPreferences userPreferences;
  bool dataLoaded = false;

  bool showTitle = true;

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