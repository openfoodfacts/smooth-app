import 'package:openfoodfacts/openfoodfacts.dart';

extension ProductNutritionExtension on Product {
  /// Returns the value of [nutrient] for [perSize], or null if unknown.
  double? getNutrientValue(Nutrient nutrient, PerSize perSize) =>
      nutriments?.getValue(nutrient, perSize);

  bool get hasNutritionData => nutriments?.isEmpty() == false;
}
