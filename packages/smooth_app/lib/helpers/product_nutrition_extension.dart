import 'package:openfoodfacts/openfoodfacts.dart';

/// Nutrition facts of a [Product]: the as sold values.
// TODO(monsieurtanuki): move to off-dart.
extension ProductNutritionExtension on Product {
  /// Sources in the server's priority order.
  static const List<String> serverSources = <String>[
    NutritionSetKey.sourceManufacturer,
    NutritionSetKey.sourcePackaging,
  ];

  /// Sources in the editor's priority order: the end-user's values first.
  static const List<String> editorSources = <String>[
    NutritionSetKey.sourcePackaging,
    NutritionSetKey.sourceManufacturer,
  ];

  /// Returns the value and unit of [nutrient] for [perSize], or null.
  NutritionValue? getNutrientValue(Nutrient nutrient, PerSize perSize) =>
      getNutritionValues(perSize)[nutrient];

  /// Returns the as sold values for [perSize], each one from the first of
  /// [sources] that has it.
  ///
  /// Old `nutriments` values, if [withOldValues], are converted and overridden
  /// by the new ones.
  // TODO(UrbanFercec): also read the per 100ml and per serving sets.
  Map<Nutrient, NutritionValue> getNutritionValues(
    PerSize perSize, {
    List<String> sources = serverSources,
    bool withOldValues = true,
  }) {
    final Map<Nutrient, NutritionValue> result = <Nutrient, NutritionValue>{};
    final List<NutritionSet> inputSets =
        NutritionHelper().getInputSets(this) ?? <NutritionSet>[];
    <Nutrient, NutritionValue>{
      if (withOldValues) ..._getOldNutritionValues(perSize),
      for (final String source in sources.reversed)
        ...?NutritionHelper()
            .getNutritionSet(
              inputSets,
              NutritionSetKey(
                source: source,
                preparation: NutritionSetKey.preparationAsSold,
                perSize: perSize,
              ),
            )
            ?.nutritionValues,
    }.forEach((Nutrient nutrient, NutritionValue nutritionValue) {
      final NutritionValue? numberValue = _getNumber(nutritionValue);
      if (numberValue != null) {
        result[nutrient] = numberValue;
      }
    });
    return result;
  }

  bool get hasNutritionData =>
      getNutritionValues(PerSize.oneHundredGrams).isNotEmpty ||
      getNutritionValues(PerSize.serving).isNotEmpty;

  bool get hasNoNutritionData =>
      noNutritionData ??
      NutritionHelper().getNoNutritionDataOnPackaging(this) ??
      false;

  /// Values saved by the app and not refreshed yet have no number.
  static NutritionValue? _getNumber(NutritionValue nutritionValue) {
    final num? value =
        nutritionValue.value ?? num.tryParse(nutritionValue.valueString ?? '');
    return value == null
        ? null
        : NutritionValue(
            value: value,
            valueString: nutritionValue.valueString,
            unit: nutritionValue.unit,
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
