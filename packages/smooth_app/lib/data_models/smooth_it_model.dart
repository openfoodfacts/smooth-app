// Package imports:
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:smooth_app/data_models/product_list.dart';
import 'package:openfoodfacts/personalized_search/matched_product.dart';
import 'package:smooth_app/data_models/product_preferences.dart';

class SmoothItModel {
  static const int MATCH_INDEX_YES = 0;
  static const int MATCH_INDEX_MAYBE = 1;
  static const int MATCH_INDEX_NO = 2;
  static const int MATCH_INDEX_ALL = 3;

  final Map<int, List<MatchedProduct>> _categorizedProducts =
      <int, List<MatchedProduct>>{};
  late List<MatchedProduct> _allProducts;
  bool _nextRefreshIsJustChangingTabs = false;

  void refresh(
    final ProductList productList,
    final ProductPreferences productPreferences,
  ) {
    if (_nextRefreshIsJustChangingTabs) {
      _nextRefreshIsJustChangingTabs = false;
      return;
    }
    final List<Product> unprocessedProducts = productList.getList();
    _allProducts = MatchedProduct.sort(unprocessedProducts, productPreferences);
    _categorizedProducts.clear();
    for (final MatchedProduct matchededProduct in _allProducts) {
      final int index = getMatchIndex(matchededProduct);
      if (_categorizedProducts[index] == null) {
        _categorizedProducts[index] = <MatchedProduct>[];
      }
      _categorizedProducts[index]!.add(matchededProduct);
    }
  }

  void setNextRefreshAsJustChangingTabs() =>
      _nextRefreshIsJustChangingTabs = true;

  List<MatchedProduct> getMatchedProducts(final int matchIndex) =>
      matchIndex == MATCH_INDEX_ALL
          ? _allProducts
          : _categorizedProducts[matchIndex] ?? <MatchedProduct>[];

  static int getMatchIndex(final MatchedProduct matchedProduct) {
    if ((matchedProduct.status == null) ||
        (matchedProduct.status == MatchedProductStatus.UNKNOWN)) {
      return MATCH_INDEX_MAYBE;
    } else if (matchedProduct.status == MatchedProductStatus.YES) {
      return MATCH_INDEX_YES;
    } else {
      return MATCH_INDEX_NO;
    }
  }
}
