import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/data_models/match.dart';

class SmoothItModel extends ChangeNotifier {
  SmoothItModel(this.unprocessedProducts, final BuildContext context) {
    _loadData(context);
    scrollController.addListener(_scrollListener);
  }

  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _loadData(final BuildContext context) async {
    try {
      dataLoaded = await processProductList(context);
      notifyListeners();
      return true;
    } catch (e) {
      print('An error occurred while processing the product list : $e');
      dataLoaded = false;
      return false;
    }
  }

  List<Product> unprocessedProducts;
  List<RankedProduct> products;

  bool dataLoaded = false;

  bool showTitle = true;

  Future<bool> processProductList(final BuildContext context) async {
    try {
      final UserPreferencesModel model = UserPreferencesModel();
      await model.loadData(context);
      products = Match.sort(unprocessedProducts, model);
      products.sort(
          (RankedProduct a, RankedProduct b) => b.score.compareTo(a.score));
      print('Processed products');
      notifyListeners();
      return true;
    } catch (e) {
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
