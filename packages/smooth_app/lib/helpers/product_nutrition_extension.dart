import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';

extension ProductNutritionExtension on Product {
  /// Returns the value of [nutrient] per 100g (weights in grams), or null.
  double? getNutrientValuePer100(Nutrient nutrient) {
    final NutritionValue? nutritionValue = _getAsSoldValues()[nutrient];
    final num? value = nutritionValue?.value;
    final Unit? unit = nutritionValue?.unit;
    if (value == null || unit == null) {
      return null;
    }
    return NutritionContainerHelper.convertWeightToG(value.toDouble(), unit);
  }

  /// Input sets are checked too, as local changes don't update the aggregate.
  bool get hasNutritionData =>
      _getAsSoldValues().isNotEmpty ||
      (NutritionHelper().getInputSets(this) ?? <NutritionSet>[]).any(
        (NutritionSet set) =>
            set.key.preparation == NutritionSetKey.preparationAsSold &&
            set.key.source != NutritionSetKey.sourceEstimate &&
            set.nutritionValues?.isNotEmpty == true,
      );

  /// Same rule as the server for the former `nutriments`: values of the
  /// aggregated set, but only as sold, per 100g or 100ml, and without
  /// estimates (except sugars).
  Map<Nutrient, NutritionValue> _getAsSoldValues() {
    final NutritionSet? aggregatedSet = NutritionHelper().getAggregatedSet(
      this,
    );
    final Map<Nutrient, NutritionValue> result = <Nutrient, NutritionValue>{};
    if (aggregatedSet == null ||
        aggregatedSet.key.preparation != NutritionSetKey.preparationAsSold ||
        (aggregatedSet.key.perSize != PerSize.oneHundredGrams &&
            aggregatedSet.key.perSize != PerSize.oneHundredMilliliters)) {
      return result;
    }
    aggregatedSet.nutritionValues?.forEach((
      Nutrient nutrient,
      NutritionValue value,
    ) {
      if (value.source != NutritionSetKey.sourceEstimate ||
          nutrient == Nutrient.addedSugars) {
        result[nutrient] = value;
      }
    });
    return result;
  }
}
