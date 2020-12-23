import 'package:openfoodfacts/model/IngredientsAnalysisTags.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/match.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

@deprecated
class FilterRankingHelper {
  // TODO(monsieurtanuki): remove the file completely?
  @deprecated
  static const Map<int, int> _NOVA_GROUP_POINTS = <int, int>{
    // TODO(monsieurtanuki): still relevant?
    1: 10,
    2: 5,
    3: 0,
    4: -10,
  };
  @deprecated
  static const int _NOVA_GROUP_POINTS_DEFAULT =
      0; // TODO(monsieurtanuki): still relevant?

  @deprecated
  static const Map<String, int> _NUTRISCORE_POINTS = <String, int>{
    // TODO(monsieurtanuki): still relevant?
    'a': 10,
    'b': 5,
    'c': 0,
    'd': -5,
    'e': -10,
  };
  @deprecated
  static const int _NUTRISCORE_POINTS_DEFAULT =
      0; // TODO(monsieurtanuki): still relevant?

  @deprecated
  static const Map<String, int> _MAX_POINTS = <String, int>{
    // TODO(monsieurtanuki): still relevant?
    PreferencesVariable.VEGAN: 10,
    PreferencesVariable.VEGETARIAN: 10,
    PreferencesVariable.GLUTEN_FREE: 10,
    PreferencesVariable.ORGANIC_LABELS: 0,
    PreferencesVariable.FAIR_TRADE_LABELS: 0,
    PreferencesVariable.PALM_FREE_LABELS: 10,
    PreferencesVariable.ADDITIVES: 10,
    PreferencesVariable.NOVA_GROUP: 0,
    PreferencesVariable.NUTRI_SCORE: 10,
  };

  @deprecated
  static List<RankedProduct> process(
      final List<Product> products, final UserPreferencesModel model) {
    final List<RankedProduct> result = <RankedProduct>[];
    for (final Product product in products) {
      final Match match = Match(product, model);
      result.add(RankedProduct(product: product, score: match.score));
    }
    result
        .sort((RankedProduct a, RankedProduct b) => b.score.compareTo(a.score));
    return result;
  }

  @deprecated
  static bool isVegan(
          Product product) => // TODO(monsieurtanuki): still relevant?
      product.ingredientsAnalysisTags != null &&
      product.ingredientsAnalysisTags.veganStatus == VeganStatus.IS_VEGAN;

  @deprecated
  static bool isVegetarian(
          Product product) => // TODO(monsieurtanuki): still relevant?
      product.ingredientsAnalysisTags != null &&
      product.ingredientsAnalysisTags.vegetarianStatus ==
          VegetarianStatus.IS_VEGETARIAN;

  @deprecated
  static bool isGlutenFree(Product product) =>
      false; // TODO(monsieurtanuki): still relevant?
  // TODO(primael): missing implementation

  @deprecated
  static int organicPoints(Product product) =>
      0; // TODO(monsieurtanuki): still relevant?
  // TODO(primael): missing implementation

  @deprecated
  static int fairTradePoints(Product product) =>
      0; // TODO(monsieurtanuki): still relevant?
  // TODO(primael): missing implementation

  @deprecated
  static int palmFreePoints(Product product) {
    // TODO(monsieurtanuki): still relevant?
    if (product.ingredientsAnalysisTags != null &&
        product.ingredientsAnalysisTags.palmOilFreeStatus !=
            PalmOilFreeStatus.MAYBE) {
      return product.ingredientsAnalysisTags.palmOilFreeStatus ==
              PalmOilFreeStatus.IS_PALM_OIL_FREE
          ? 10
          : -10;
    } else {
      return 0;
    }
  }

  @deprecated
  static int additivesPoints(
          Product product) => // TODO(monsieurtanuki): still relevant?
      product.additives != null ? product.additives.ids.length * -10 : 10;

  @deprecated
  static int novaGroupPoints(
          Product product) => // TODO(monsieurtanuki): still relevant?
      _NOVA_GROUP_POINTS[product.nutriments.novaGroup] ??
      _NOVA_GROUP_POINTS_DEFAULT;

  @deprecated
  static int nutriScorePoints(
          Product product) => // TODO(monsieurtanuki): still relevant?
      _NUTRISCORE_POINTS[product.nutriscore] ?? _NUTRISCORE_POINTS_DEFAULT;
}
