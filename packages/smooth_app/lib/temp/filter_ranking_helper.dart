import 'package:openfoodfacts/model/IngredientsAnalysisTags.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

enum RankingType { TOP_PICKS, CONTENDERS, DISMISSED }

class FilterRankingHelper {
  static const Map<int, int> _NOVA_GROUP_POINTS = <int, int>{
    1: 10,
    2: 5,
    3: 0,
    4: -10,
  };
  static const int _NOVA_GROUP_POINTS_DEFAULT = 0;

  static const Map<String, int> _NUTRISCORE_POINTS = <String, int>{
    'a': 10,
    'b': 5,
    'c': 0,
    'd': -5,
    'e': -10,
  };
  static const int _NUTRISCORE_POINTS_DEFAULT = 0;

  static const Map<String, int> _MAX_POINTS = <String, int>{
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

  static List<RankedProduct> process(
      final List<Product> products, final UserPreferencesModel model) {
    final List<RankedProduct> result = <RankedProduct>[];
    for (final Product product in products) {
      result.add(_getRankedProduct(product, model));
    }
    result
        .sort((RankedProduct a, RankedProduct b) => b.score.compareTo(a.score));
    _setHeader(result);
    return result;
  }

  static void _setHeader(final List<RankedProduct> list) {
    int topPicksCounter = 0;
    int contendersCounter = 0;
    int dismissedCounter = 0;
    for (final RankedProduct rankedProduct in list) {
      switch (rankedProduct.type) {
        case RankingType.DISMISSED:
          dismissedCounter++;
          break;
        case RankingType.TOP_PICKS:
          topPicksCounter++;
          break;
        case RankingType.CONTENDERS:
          contendersCounter++;
          break;
      }
    }
    if (topPicksCounter == 0) {
      list.insert(
          0,
          RankedProduct(
              type: RankingType.TOP_PICKS,
              product: null,
              isHeader: true,
              score: 0));
      topPicksCounter++;
    } else {
      list.first.isHeader = true;
    }

    if (contendersCounter == 0) {
      list.insert(
          topPicksCounter,
          RankedProduct(
              type: RankingType.CONTENDERS,
              product: null,
              isHeader: true,
              score: 0));
      contendersCounter++;
    } else {
      list[topPicksCounter].isHeader = true;
    }

    if (dismissedCounter == 0) {
      list.insert(
          topPicksCounter + contendersCounter,
          RankedProduct(
              type: RankingType.DISMISSED,
              product: null,
              isHeader: true,
              score: 0));
    } else {
      list[topPicksCounter + contendersCounter].isHeader = true;
    }
  }

  static RankedProduct _getRankedProduct(
    final Product product,
    final UserPreferencesModel model,
  ) {
    bool isFiltered = false;
    int score = 0;
    for (final String variable in UserPreferencesModel.getVariables()) {
      final int points = _getPoints(variable, product);
      if (model.getStringValue(variable) == PreferencesValue.MANDATORY &&
          points <= 0) {
        isFiltered = true;
      }
      score += points * model.getScoreIndex(variable);
    }
    if (isFiltered) {
      return RankedProduct(
        product: product,
        type: RankingType.DISMISSED,
        score: score,
      );
    }
    final int max = maximumScore(model);
    if (score < max * 0.2) {
      return RankedProduct(
        product: product,
        type: RankingType.DISMISSED,
        score: score,
      );
    }
    if (score > max * 0.8) {
      return RankedProduct(
        product: product,
        type: RankingType.TOP_PICKS,
        score: score,
      );
    }
    return RankedProduct(
      product: product,
      type: RankingType.CONTENDERS,
      score: score,
    );
  }

  static bool isVegan(Product product) =>
      product.ingredientsAnalysisTags != null &&
      product.ingredientsAnalysisTags.veganStatus == VeganStatus.IS_VEGAN;

  static bool isVegetarian(Product product) =>
      product.ingredientsAnalysisTags != null &&
      product.ingredientsAnalysisTags.vegetarianStatus ==
          VegetarianStatus.IS_VEGETARIAN;

  static bool isGlutenFree(Product product) => false;
  // TODO(primael): missing implementation

  static int organicPoints(Product product) => 0;
  // TODO(primael): missing implementation

  static int fairTradePoints(Product product) => 0;
  // TODO(primael): missing implementation

  static int palmFreePoints(Product product) {
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

  static int additivesPoints(Product product) =>
      product.additives != null ? product.additives.ids.length * -10 : 10;

  static int novaGroupPoints(Product product) =>
      _NOVA_GROUP_POINTS[product.nutriments.novaGroup] ??
      _NOVA_GROUP_POINTS_DEFAULT;

  static int nutriScorePoints(Product product) =>
      _NUTRISCORE_POINTS[product.nutriscore] ?? _NUTRISCORE_POINTS_DEFAULT;

  static int _getPoints(final String variable, final Product product) {
    switch (variable) {
      case PreferencesVariable.VEGAN:
        return isVegan(product) ? _MAX_POINTS[variable] : 0;
      case PreferencesVariable.VEGETARIAN:
        return isVegetarian(product) ? _MAX_POINTS[variable] : 0;
      case PreferencesVariable.GLUTEN_FREE:
        return isGlutenFree(product) ? _MAX_POINTS[variable] : 0;
      case PreferencesVariable.ORGANIC_LABELS:
        return organicPoints(product);
      case PreferencesVariable.FAIR_TRADE_LABELS:
        return fairTradePoints(product);
      case PreferencesVariable.PALM_FREE_LABELS:
        return palmFreePoints(product);
      case PreferencesVariable.ADDITIVES:
        return additivesPoints(product);
      case PreferencesVariable.NOVA_GROUP:
        return novaGroupPoints(product);
      case PreferencesVariable.NUTRI_SCORE:
        return nutriScorePoints(product);
    }
    return 0;
  }

  static int maximumScore(final UserPreferencesModel model) {
    int score = 0;
    _MAX_POINTS.forEach((String variable, int maxPoints) =>
        score += maxPoints * model.getScoreIndex(variable));
    return score;
  }
}
