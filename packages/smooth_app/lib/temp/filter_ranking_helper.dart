
import 'package:openfoodfacts/model/IngredientsAnalysisTags.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/temp/user_preferences.dart';

enum RankingType {
  TOP_PICKS,
  CONTENDERS,
  DISMISSED
}

class FilterRankingHelper {

  static Map<RankingType, List<Product>> process(List<Product> products, UserPreferences userPreferences) {
    final Map<RankingType, List<Product>> result = <RankingType, List<Product>>{
      RankingType.TOP_PICKS: <Product>[],
      RankingType.CONTENDERS: <Product>[],
      RankingType.DISMISSED: <Product>[]
    };

    final Map<Product, int> topPicks = <Product, int>{};
    final Map<Product, int> contenders = <Product, int>{};
    final Map<Product, int> dismissed = <Product, int>{};

    for(final Product product in products) {
      bool isFiltered = false;
      int score = 0;
      for(final UserPreferencesVariable variable in userPreferences.getActiveVariables()) {
        print(variable);
        switch(variable) {
          case UserPreferencesVariable.VEGAN:
            if(!isVegan(product)) {
              dismissed[product] = score;
              isFiltered = true;
            }
            break;
          case UserPreferencesVariable.VEGETARIAN:
            if(!isVegetarian(product)) {
              dismissed[product] = score;
              isFiltered = true;
            }
            break;
          case UserPreferencesVariable.GLUTEN_FREE:
            if(!isGlutenFree(product)) {
              dismissed[product] = score;
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
          dismissed[product] = score;
        } else if(score > 100) {
          topPicks[product] = score;
        } else {
          contenders[product] = score;
        }
      }
    }

    Iterable<int> sortedScores = ((dismissed.values.toList())..sort((int a, int b) {
      return a.compareTo(b);
    })).reversed;

    for(final int score in sortedScores) {
      for(final Product product in dismissed.keys) {
        if(dismissed[product] == score && !result[RankingType.DISMISSED].contains(product)) {
          result[RankingType.DISMISSED].add(product);
        }
      }
    }

    sortedScores = ((topPicks.values.toList())..sort((int a, int b) {
      return a.compareTo(b);
    })).reversed;

    for(final int score in sortedScores) {
      for(final Product product in topPicks.keys) {
        if(topPicks[product] == score && !result[RankingType.TOP_PICKS].contains(product)) {
          result[RankingType.TOP_PICKS].add(product);
        }
      }
    }

    sortedScores = ((contenders.values.toList())..sort((int a, int b) {
      return a.compareTo(b);
    })).reversed;

    for(final int score in sortedScores) {
      for(final Product product in contenders.keys) {
        if(contenders[product] == score && !result[RankingType.CONTENDERS].contains(product)) {
          result[RankingType.CONTENDERS].add(product);
        }
      }
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
    // TODO(primael): missing implementation
    return 0;
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

}