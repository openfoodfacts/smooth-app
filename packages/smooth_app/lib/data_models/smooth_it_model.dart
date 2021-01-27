import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/data_models/match.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/data_models/product_list.dart';

class SmoothItModel {
  static const int MATCH_INDEX_YES = 0;
  static const int MATCH_INDEX_MAYBE = 1;
  static const int MATCH_INDEX_NO = 2;
  static const int MATCH_INDEX_ALL = 3;

  final Map<int, List<RankedProduct>> _categorizedProducts =
      <int, List<RankedProduct>>{};
  List<RankedProduct> _allProducts;
  bool _nextRefreshIsJustChangingTabs = false;

  void refresh(
    final ProductList productList,
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
  ) {
    if (_nextRefreshIsJustChangingTabs) {
      _nextRefreshIsJustChangingTabs = false;
      return;
    }
    final List<Product> unprocessedProducts = productList.getUniqueList();
    _allProducts =
        Match.sort(unprocessedProducts, userPreferences, userPreferencesModel);
    _categorizedProducts.clear();
    for (final RankedProduct rankedProduct in _allProducts) {
      final int index = getMatchIndex(rankedProduct);
      if (_categorizedProducts[index] == null) {
        _categorizedProducts[index] = <RankedProduct>[];
      }
      _categorizedProducts[index].add(rankedProduct);
    }
  }

  void setNextRefreshAsJustChangingTabs() =>
      _nextRefreshIsJustChangingTabs = true;

  List<RankedProduct> getRankedProducts(final int matchIndex) =>
      matchIndex == MATCH_INDEX_ALL
          ? _allProducts
          : _categorizedProducts[matchIndex] ?? <RankedProduct>[];

  static int getMatchIndex(final RankedProduct product) =>
      product.match.status == null
          ? MATCH_INDEX_MAYBE
          : product.match.status
              ? MATCH_INDEX_YES
              : MATCH_INDEX_NO;

  static bool getBoolFromMatchIndex(final int index) =>
      index == MATCH_INDEX_MAYBE ? null : index == MATCH_INDEX_YES;
}
