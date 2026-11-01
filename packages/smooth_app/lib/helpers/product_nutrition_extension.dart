import 'package:openfoodfacts/openfoodfacts.dart';

extension ProductNutritionExtension on Product {
  /// Returns the value of [nutrient] per 100g, or null if unknown.
  double? getNutrientValuePer100(Nutrient nutrient) =>
      nutriments?.getValue(nutrient, PerSize.oneHundredGrams);

  bool get hasNutritionData => nutriments?.isEmpty() == false;
}
