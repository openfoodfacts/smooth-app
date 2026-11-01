import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';

extension ProductNutritionExtension on Product {
  /// Returns the value of [nutrient] per 100g (weights in grams), or null.
  double? getNutrientValuePer100(final Nutrient nutrient) {
    final NutritionValue? nutritionValue = _asSoldValues[nutrient];
    final num? value = nutritionValue?.value;
    final Unit? unit = nutritionValue?.unit;
    if (value == null || unit == null) {
      return null;
    }
    return NutritionContainerHelper.convertWeightToG(value.toDouble(), unit);
  }

  bool get hasNutritionData => _asSoldValues.isNotEmpty;

  /// Same rule as the server for the former `nutriments`: values of the
  /// aggregated set, but only as sold and without estimates (except sugars).
  Map<Nutrient, NutritionValue> get _asSoldValues {
    final NutritionSet? aggregatedSet = NutritionHelper().getAggregatedSet(
      this,
    );
    final Map<Nutrient, NutritionValue> result = <Nutrient, NutritionValue>{};
    if (aggregatedSet?.key.preparation != NutritionSetKey.preparationAsSold) {
      return result;
    }
    aggregatedSet!.nutritionValues?.forEach((
      final Nutrient nutrient,
      final NutritionValue value,
    ) {
      if (value.source != NutritionSetKey.sourceEstimate ||
          nutrient == Nutrient.addedSugars) {
        result[nutrient] = value;
      }
    });
    return result;
  }
}
