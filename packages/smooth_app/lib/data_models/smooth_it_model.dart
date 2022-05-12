import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/smooth_matched_product.dart';

/// Tabs where ranked products are displayed
enum MatchTab {
  YES,
  MAYBE,
  NO,
  ALL,
}

class SmoothItModel {
  final Map<MatchTab, List<MatchedProduct>> _categorizedProducts =
      <MatchTab, List<MatchedProduct>>{};

  void refresh(
    final List<Product> products,
    final ProductPreferences productPreferences,
    final UserPreferences userPreferences,
  ) {
    final List<MatchedProduct> allProducts = MatchedProduct.sort(
      products,
      productPreferences,
      userPreferences,
    );
    _categorizedProducts.clear();
    _categorizedProducts[MatchTab.ALL] = allProducts;
    for (final MatchedProduct matchedProduct in allProducts) {
      final MatchTab matchTab = _getMatchTab(matchedProduct);
      if (_categorizedProducts[matchTab] == null) {
        _categorizedProducts[matchTab] = <MatchedProduct>[];
      }
      _categorizedProducts[matchTab]!.add(matchedProduct);
    }
  }

  List<MatchedProduct> getMatchedProducts(final MatchTab matchTab) =>
      _categorizedProducts[matchTab] ?? <MatchedProduct>[];

  static MatchTab _getMatchTab(final MatchedProduct matchedProduct) {
    if ((matchedProduct.status == null) ||
        (matchedProduct.status == MatchedProductStatus.UNKNOWN)) {
      return MatchTab.MAYBE;
    }
    if (matchedProduct.status == MatchedProductStatus.YES) {
      return MatchTab.YES;
    }
    return MatchTab.NO;
  }
}
