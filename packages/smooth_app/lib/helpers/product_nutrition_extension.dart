import 'package:openfoodfacts/openfoodfacts.dart';

/// Nutrition facts of a [Product]: the packaging values, as sold.
// TODO(monsieurtanuki): move to off-dart.
extension ProductNutritionExtension on Product {
  /// Returns the value and unit of [nutrient] for [perSize], or null.
  ///
  /// Energy in kJ is computed from kcal when missing.
  NutritionValue? getNutrientValue(Nutrient nutrient, PerSize perSize) {
    final Map<Nutrient, NutritionValue> nutritionValues = getNutritionValues(
      perSize,
    );
    final NutritionValue? result = _getNumber(nutritionValues[nutrient]);
    if (result != null || nutrient != Nutrient.energyKJ) {
      return result;
    }
    final num? kCal = _getNumber(nutritionValues[Nutrient.energyKCal])?.value;
    return kCal == null
        ? null
        : NutritionValue(
            value: NutrimentsHelper.fromKCalToKJ(kCal.toDouble()).round(),
            unit: Unit.KJ,
          );
  }

  /// Returns the packaging as sold values for [perSize].
  ///
  /// Old `nutriments` values are converted, and overridden by the new ones.
  // TODO(UrbanFercec): also read the manufacturer, per 100ml and per serving sets.
  Map<Nutrient, NutritionValue> getNutritionValues(PerSize perSize) =>
      <Nutrient, NutritionValue>{
        ..._getOldNutritionValues(perSize),
        ...?NutritionHelper()
            .getNutritionSet(
              NutritionHelper().getInputSets(this) ?? <NutritionSet>[],
              NutritionSetKey(
                source: NutritionSetKey.sourcePackaging,
                preparation: NutritionSetKey.preparationAsSold,
                perSize: perSize,
              ),
            )
            ?.nutritionValues,
      };

  bool get hasNutritionData =>
      getNutritionValues(PerSize.oneHundredGrams).isNotEmpty ||
      getNutritionValues(PerSize.serving).isNotEmpty;

  bool get hasNoNutritionData =>
      noNutritionData ??
      NutritionHelper().getNoNutritionDataOnPackaging(this) ??
      false;

  /// Values saved by the app and not refreshed yet have no number.
  static NutritionValue? _getNumber(NutritionValue? nutritionValue) {
    final num? value =
        nutritionValue?.value ??
        num.tryParse(nutritionValue?.valueString ?? '');
    return value == null
        ? null
        : NutritionValue(
            value: value,
            unit: nutritionValue!.unit,
            modifier: nutritionValue.modifier,
          );
  }

  /// Old `nutriments` weights are in grams.
  Map<Nutrient, NutritionValue> _getOldNutritionValues(PerSize perSize) {
    final Map<Nutrient, NutritionValue> result = <Nutrient, NutritionValue>{};
    // ignore: deprecated_member_use
    final Nutriments? oldNutriments = nutriments;
    if (oldNutriments == null) {
      return result;
    }
    for (final Nutrient nutrient in Nutrient.values) {
      final double? value = oldNutriments.getValue(nutrient, perSize);
      if (value != null) {
        result[nutrient] = NutritionValue(
          value: value,
          unit:
              nutrient.typicalUnit == Unit.MILLI_G ||
                  nutrient.typicalUnit == Unit.MICRO_G
              ? Unit.G
              : nutrient.typicalUnit,
        );
      }
    }
    return result;
  }
}
