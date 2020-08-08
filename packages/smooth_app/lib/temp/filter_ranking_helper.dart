
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/IngredientsAnalysisTags.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/temp/user_preferences.dart';

enum RankingType {
  TOP_PICKS,
  CONTENDERS,
  DISMISSED
}

class FilterRankingHelper {

  static List<RankedProduct> process(List<Product> products, UserPreferences userPreferences) {
    final List<RankedProduct> result = <RankedProduct>[];

    int topPicksCounter = 0;
    int contendersCounter = 0;
    int dismissedCounter = 0;

    for(final Product product in products) {
      bool isFiltered = false;
      int score = 0;
      for(final UserPreferencesVariable variable in userPreferences.getActiveVariables()) {
        print(variable);
        switch(variable) {
          case UserPreferencesVariable.VEGAN:
            if(!isVegan(product)) {
              result.add(RankedProduct(
                product: product,
                type: RankingType.DISMISSED,
                score: score,
              ));
              dismissedCounter++;
              isFiltered = true;
            }
            break;
          case UserPreferencesVariable.VEGETARIAN:
            if(!isVegetarian(product)) {
              result.add(RankedProduct(
                product: product,
                type: RankingType.DISMISSED,
                score: score,
              ));
              dismissedCounter++;
              isFiltered = true;
            }
            break;
          case UserPreferencesVariable.GLUTEN_FREE:
            if(!isGlutenFree(product)) {
              result.add(RankedProduct(
                product: product,
                type: RankingType.DISMISSED,
                score: score,
              ));
              dismissedCounter++;
              isFiltered = true;
            }
            break;
          case UserPreferencesVariable.ORGANIC_LABELS:
            score += organicPoints(product);
            break;
          case UserPreferencesVariable.FAIR_TRADE_LABELS:
            score += fairTradePoints(product);
            break;
          case UserPreferencesVariable.PALM_FREE_LABELS:
            score += palmFreePoints(product);
            break;
          case UserPreferencesVariable.ADDITIVES:
            score += additivesPoints(product);
            break;
          case UserPreferencesVariable.NOVA_GROUP:
            score += novaGroupPoints(product);
            break;
          case UserPreferencesVariable.NUTRI_SCORE:
            score += nutriScorePoints(product);
            break;
        }

        if(isFiltered) {
          break;
        }
      }
      if(!isFiltered) {
        if(score < 0) {
          result.add(RankedProduct(
            product: product,
            type: RankingType.DISMISSED,
            score: score,
          ));
          dismissedCounter++;
        } else if(score > 100) {
          result.add(RankedProduct(
            product: product,
            type: RankingType.TOP_PICKS,
            score: score,
          ));
          topPicksCounter++;
        } else {
          result.add(RankedProduct(
            product: product,
            type: RankingType.CONTENDERS,
            score: score,
          ));
          contendersCounter++;
        }
      }
    }

    result.sort((RankedProduct a, RankedProduct b) => b.score.compareTo(a.score));

    if(topPicksCounter == 0) {
      result.insert(0, RankedProduct(type: RankingType.TOP_PICKS, product: null, isHeader: true, score: 0));
      topPicksCounter++;
    } else {
      result.first.isHeader = true;
    }

    if(contendersCounter == 0) {
      result.insert(topPicksCounter, RankedProduct(type: RankingType.CONTENDERS, product: null, isHeader: true, score: 0));
      contendersCounter++;
    } else {
      result[topPicksCounter].isHeader = true;
    }

    if(dismissedCounter == 0) {
      result.insert(topPicksCounter + contendersCounter, RankedProduct(type: RankingType.DISMISSED, product: null, isHeader: true, score: 0));
    } else {
      result[topPicksCounter + contendersCounter].isHeader = true;
    }

    return result;
  }

  static bool isVegan(Product product) {
    if (product.ingredientsAnalysisTags != null) {
      return product.ingredientsAnalysisTags.veganStatus == VeganStatus.IS_VEGAN;
    } else {
      return false;
    }
  }

  static bool isVegetarian(Product product) {
    if (product.ingredientsAnalysisTags != null) {
      return product.ingredientsAnalysisTags.vegetarianStatus == VegetarianStatus.IS_VEGETARIAN;
    } else {
      return false;
    }
  }

  static bool isGlutenFree(Product product) {
    return false;
  }

  static int organicPoints(Product product) {
    // TODO(primael): missing implementation
    return 0;
  }

  static int fairTradePoints(Product product) {
    // TODO(primael): missing implementation
    return 0;
  }

  static int palmFreePoints(Product product) {
    if (product.ingredientsAnalysisTags != null && product.ingredientsAnalysisTags.palmOilFreeStatus != PalmOilFreeStatus.MAYBE) {
      return product.ingredientsAnalysisTags.palmOilFreeStatus == PalmOilFreeStatus.MAYBE ? 5 : -5;
    } else {
      return 0;
    }
  }

  static int additivesPoints(Product product) {
    return product.additives != null ? product.additives.ids.length * 10 : 0;
  }

  static int novaGroupPoints(Product product) {
    return product.nutriments.novaGroup == 4 ? -10 : 0;
  }

  static int nutriScorePoints(Product product) {
    switch(product.nutriscore) {
      case 'a':
        return 10;
        break;
      case 'b':
        return 5;
        break;
      case 'c':
        return 0;
        break;
      case 'd':
        return -5;
        break;
      case 'e':
        return -10;
        break;
      default:
        return 0;
        break;
    }
  }

  static String getRankingTypeTitle(RankingType type) {
    switch(type) {
      case RankingType.TOP_PICKS:
        return 'Top picks';
        break;
      case RankingType.CONTENDERS:
        return 'Contenders';
        break;
      case RankingType.DISMISSED:
        return 'Dismissed';
        break;
      default:
        return 'Ranking type';
        break;
    }
  }

  static Color getRankingTypeColor(RankingType type) {
    switch(type) {
      case RankingType.TOP_PICKS:
        return Colors.greenAccent;
        break;
      case RankingType.CONTENDERS:
        return Colors.blueAccent;
        break;
      case RankingType.DISMISSED:
        return Colors.redAccent;
        break;
      default:
        return Colors.grey;
        break;
    }
  }

}