
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
      for(final UserPreferencesVariable variable in UserPreferencesVariableExtension.getVariables()) {
        switch(variable) {
          case UserPreferencesVariable.VEGAN:
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && !isVegan(product)) {
              isFiltered = true;
            } else {
              score += 10 * userPreferences.getVariable(variable).value;
            }
            break;
          case UserPreferencesVariable.VEGETARIAN:
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && !isVegetarian(product)) {
              isFiltered = true;
            } else {
              score += 10 * userPreferences.getVariable(variable).value;
            }
            break;
          case UserPreferencesVariable.GLUTEN_FREE:
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && !isGlutenFree(product)) {
              isFiltered = true;
            } else {
              score += 10 * userPreferences.getVariable(variable).value;
            }
            break;
          case UserPreferencesVariable.ORGANIC_LABELS:
            final int points = organicPoints(product);
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && points <= 0) {
              isFiltered = true;
            }
            score += points * userPreferences.getVariable(variable).value;
            break;
          case UserPreferencesVariable.FAIR_TRADE_LABELS:
            final int points = fairTradePoints(product);
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && points <= 0) {
              isFiltered = true;
            }
            score += points * userPreferences.getVariable(variable).value;
            break;
          case UserPreferencesVariable.PALM_FREE_LABELS:
            final int points = palmFreePoints(product);
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && points <= 0) {
              isFiltered = true;
            }
            score += points * userPreferences.getVariable(variable).value;
            break;
          case UserPreferencesVariable.ADDITIVES:
            final int points = additivesPoints(product);
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && points <= 0) {
              isFiltered = true;
            }
            score += points * userPreferences.getVariable(variable).value;
            break;
          case UserPreferencesVariable.NOVA_GROUP:
            final int points = novaGroupPoints(product);
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && points <= 0) {
              isFiltered = true;
            }
            score += points * userPreferences.getVariable(variable).value;
            break;
          case UserPreferencesVariable.NUTRI_SCORE:
            final int points = nutriScorePoints(product);
            if(userPreferences.getVariable(variable) == UserPreferencesVariableValue.MANDATORY && points <= 0) {
              isFiltered = true;
            }
            score += points * userPreferences.getVariable(variable).value;
            break;
        }
      }
      if(!isFiltered) {
        final int max = maximumScore(userPreferences);
        if(score < (max * 0.2)) {
          result.add(RankedProduct(
            product: product,
            type: RankingType.DISMISSED,
            score: score,
          ));
          dismissedCounter++;
        } else if(score > (max * 0.8)) {
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
      } else {
        result.add(RankedProduct(
          product: product,
          type: RankingType.DISMISSED,
          score: score,
        ));
        dismissedCounter++;
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
    // TODO(primael): missing implementation
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
      return product.ingredientsAnalysisTags.palmOilFreeStatus == PalmOilFreeStatus.IS_PALM_OIL_FREE ? 10 : -10;
    } else {
      return 0;
    }
  }

  static int additivesPoints(Product product) {
    return product.additives != null ? product.additives.ids.length * -10 : 10;
  }

  static int novaGroupPoints(Product product) {
    switch(product.nutriments.novaGroup) {
      case 1:
        return 10;
        break;
      case 2:
        return 5;
        break;
      case 3:
        return 0;
        break;
      case 4:
        return -10;
      default:
        return 0;
        break;
    }
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

  static int maximumScore(UserPreferences userPreferences) {
    int score = 0;
    //vegan points
    score += 10 * userPreferences.getVariable(UserPreferencesVariable.VEGAN).value;
    //vegetarian points
    score += 10 * userPreferences.getVariable(UserPreferencesVariable.VEGETARIAN).value;
    //gluten-free points
    score += 0 * userPreferences.getVariable(UserPreferencesVariable.GLUTEN_FREE).value;
    //organic points
    score += 0 * userPreferences.getVariable(UserPreferencesVariable.ORGANIC_LABELS).value;
    //fair-trade points
    score += 0 * userPreferences.getVariable(UserPreferencesVariable.FAIR_TRADE_LABELS).value;
    //palm-free points
    score += 10 * userPreferences.getVariable(UserPreferencesVariable.PALM_FREE_LABELS).value;
    //additives points
    score += 10 * userPreferences.getVariable(UserPreferencesVariable.ADDITIVES).value;
    //nova group points
    score += 0 * userPreferences.getVariable(UserPreferencesVariable.NOVA_GROUP).value;
    //nutri-score points
    score += 10 * userPreferences.getVariable(UserPreferencesVariable.NUTRI_SCORE).value;

    return score;
  }

}