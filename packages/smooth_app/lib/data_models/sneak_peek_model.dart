import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/model/RecommendedDailyIntake.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/UnitHelper.dart';
import 'package:rubber/rubber.dart';

class SneakPeakModel extends ChangeNotifier {
  SneakPeakModel(this.product, this.rubberAnimationController) {
    try {
      recommendedDailyIntake =
          RecommendedDailyIntake.getRecommendedDailyIntakes();
      servingQuantity = product.servingQuantity ?? 100.0;
      packageQuantity = product.packagingQuantity is! int
          ? int.parse(product.packagingQuantity as String ?? '1000')
          : product.packagingQuantity as int;

      print(servingQuantity);
      print(packageQuantity);
      _calculatePercentages();
    } catch (e) {
      print('Error while getting recommendations : $e');
    }
    rubberAnimationController.animateTo(to: 0.28);
    rubberAnimationController.addListener(() {
      if (rubberAnimationController.animationState.value ==
          AnimationState.collapsed) {
        rubberAnimationController.animateTo(to: 0.28);
      }
    });
  }

  RubberAnimationController rubberAnimationController;

  Product product;
  RecommendedDailyIntake recommendedDailyIntake;

  int servingCount = 1;
  double servingQuantity = 100.0;
  int packageQuantity = 500;

  double energy = 0.0;
  double sugars = 0.0;
  double fat = 0.0;
  double saturatedFat = 0.0;
  double salt = 0.0;
  double carbohydrates = 0.0;
  double vitaminA = 0.0;
  double vitaminB1 = 0.0;
  double vitaminC = 0.0;
  double vitaminD = 0.0;
  double vitaminE = 0.0;
  double vitaminK = 0.0;

  void increaseServingCount() {
    servingCount++;
    _calculatePercentages();
    notifyListeners();
  }

  void _calculatePercentages() {
    energy = product.nutriments.energyUnit == Unit.KCAL
        ? (product.nutriments.energy /
            100 *
            servingCount *
            servingQuantity /
            recommendedDailyIntake.energyKcal.value)
        : (product.nutriments.energy /
            100 *
            servingCount *
            servingQuantity /
            recommendedDailyIntake.energyKj.value);
    sugars = product.nutriments.sugars /
        100 *
        servingCount *
        servingQuantity /
        recommendedDailyIntake.sugars.value;
    fat = product.nutriments.fat /
        100 *
        servingCount *
        servingQuantity /
        recommendedDailyIntake.fat.value;
    saturatedFat = product.nutriments.saturatedFat /
        100 *
        servingCount *
        servingQuantity /
        recommendedDailyIntake.saturatedFat.value;
    salt = product.nutriments.salt /
        100 *
        servingCount *
        servingQuantity /
        recommendedDailyIntake.sodium.value;
    carbohydrates = product.nutriments.carbohydrates /
        100 *
        servingCount *
        servingQuantity /
        recommendedDailyIntake.carbohydrates.value;
    notifyListeners();
  }
}
