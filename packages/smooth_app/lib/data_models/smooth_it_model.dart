import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/personalized_search/matched_product_v2.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

/// Tabs where ranked products are displayed
enum MatchTab {
  YES,
  MAYBE,
  NO,
  ALL,
}

class SmoothItModel {
  final Map<MatchTab, List<MatchedProductV2>> _categorizedProducts =
      <MatchTab, List<MatchedProductV2>>{};

  void refresh(
    final List<Product> products,
    final ProductPreferences productPreferences,
    final UserPreferences userPreferences,
  ) {
    final List<MatchedProductV2> allProducts = MatchedProductV2.sort(
      products,
      productPreferences,
    );
    _categorizedProducts.clear();
    _categorizedProducts[MatchTab.ALL] = allProducts;
    for (final MatchedProductV2 matchedProduct in allProducts) {
      final MatchTab matchTab = _getMatchTab(matchedProduct);
      if (_categorizedProducts[matchTab] == null) {
        _categorizedProducts[matchTab] = <MatchedProductV2>[];
      }
      _categorizedProducts[matchTab]!.add(matchedProduct);
    }
  }

  List<MatchedProductV2> getMatchedProducts(final MatchTab matchTab) =>
      _categorizedProducts[matchTab] ?? <MatchedProductV2>[];

  static MatchTab _getMatchTab(final MatchedProductV2 matchedProduct) {
    switch (matchedProduct.status) {
      case MatchedProductStatusV2.VERY_GOOD_MATCH:
      case MatchedProductStatusV2.GOOD_MATCH:
      case MatchedProductStatusV2.POOR_MATCH:
        return MatchTab.YES;
      case MatchedProductStatusV2.MAY_NOT_MATCH:
      case MatchedProductStatusV2.UNKNOWN_MATCH:
        return MatchTab.MAYBE;
      case MatchedProductStatusV2.DOES_NOT_MATCH:
        return MatchTab.NO;
    }
  }
}
