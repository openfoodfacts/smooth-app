import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/data_models/match.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class SmoothItModel {
  Future<bool> loadData(
    final List<Product> unprocessedProducts,
    final UserPreferences userPreferences,
    final UserPreferencesModel userPreferencesModel,
  ) async {
    if (_loaded) {
      return true;
    }
    final List<RankedProduct> rankedProducts =
        Match.sort(unprocessedProducts, userPreferences, userPreferencesModel);
    greenProducts.clear();
    redProducts.clear();
    whiteProducts.clear();
    for (final RankedProduct rankedProduct in rankedProducts) {
      final bool status = rankedProduct.match.status;
      List<RankedProduct> target;
      if (status == null) {
        target = whiteProducts;
      } else if (status) {
        target = greenProducts;
      } else {
        target = redProducts;
      }
      target.add(rankedProduct);
    }
    _loaded = true;
    return true;
  }

  final List<RankedProduct> greenProducts = <RankedProduct>[];
  final List<RankedProduct> redProducts = <RankedProduct>[];
  final List<RankedProduct> whiteProducts = <RankedProduct>[];
  bool _loaded = false;
}
