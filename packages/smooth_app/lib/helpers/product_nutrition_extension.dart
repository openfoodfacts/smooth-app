import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';

/// Nutrition facts of a [Product], from the API 3.5 input sets, or from the
/// old `nutriments` that only products and changes saved by older app versions
/// have.
// TODO(monsieurtanuki): move to off-dart.
extension ProductNutritionExtension on Product {
  /// Returns the as sold value of [nutrient] for [perSize] (weights in grams),
  /// or null if unknown.
  double? getNutrientValue(Nutrient nutrient, PerSize perSize) {
    final NutritionValue? result = getNutrientValueAsIs(nutrient, perSize);
    return result == null
        ? null
        : NutritionContainerHelper.convertWeightToG(
            result.value!.toDouble(),
            result.unit!,
          );
  }

  /// Returns the as sold value of [nutrient] for [perSize] with the unit it
  /// was entered in, or null if unknown.
  ///
  /// Same priority as the server: manufacturer, packaging, then usda values.
  /// Per 100g also takes a per 100ml value, or a per serving value scaled to
  /// 100. Energy in kJ is computed from kcal when missing.
  NutritionValue? getNutrientValueAsIs(Nutrient nutrient, PerSize perSize) {
    if (_hasOldNutriments) {
      final double? value = nutrient == Nutrient.energyKJ
          // ignore: deprecated_member_use
          ? nutriments!.getComputedKJ(perSize)
          // ignore: deprecated_member_use
          : nutriments!.getValue(nutrient, perSize);
      return value == null
          ? null
          : NutritionValue(value: value, unit: _oldUnit(nutrient));
    }
    final List<NutritionSet> sets =
        NutritionHelper().getInputSets(this) ?? <NutritionSet>[];
    final List<PerSize> perSizes = <PerSize>[
      perSize,
      if (perSize == PerSize.oneHundredGrams) ...<PerSize>[
        PerSize.oneHundredMilliliters,
        PerSize.serving,
      ],
    ];
    for (final String source in _sources) {
      for (final PerSize setPerSize in perSizes) {
        for (final NutritionSet set in sets.where(
          (NutritionSet set) =>
              set.key.source == source &&
              set.key.perSize == setPerSize &&
              set.key.preparation == NutritionSetKey.preparationAsSold,
        )) {
          final bool needsScaling =
              setPerSize == PerSize.serving && perSize != PerSize.serving;
          final NutritionValue? result = _getValue(
            set,
            nutrient,
            needsScaling: needsScaling,
          );
          if (result != null) {
            return result;
          }
          if (nutrient == Nutrient.energyKJ) {
            final double? kJ = NutritionContainerHelper.getKJFromKCal(
              _getValue(
                set,
                Nutrient.energyKCal,
                needsScaling: needsScaling,
              )?.value,
            );
            if (kJ != null) {
              return NutritionValue(value: kJ, unit: Unit.KJ);
            }
          }
        }
      }
    }
    return null;
  }

  bool get hasNoNutritionData =>
      noNutritionData ??
      NutritionHelper().getNoNutritionDataOnPackaging(this) ??
      false;

  bool get hasNutritionData =>
      _hasOldNutriments ||
      (NutritionHelper().getInputSets(this) ?? <NutritionSet>[]).any(
        (NutritionSet set) =>
            _sources.contains(set.key.source) &&
            set.key.preparation == NutritionSetKey.preparationAsSold &&
            set.nutritionValues?.isNotEmpty == true,
      );

  static const List<String> _sources = <String>[
    NutritionSetKey.sourceManufacturer,
    NutritionSetKey.sourcePackaging,
    // TODO(monsieurtanuki): add the usda source to off-dart.
    'usda',
  ];

  // ignore: deprecated_member_use
  bool get _hasOldNutriments => nutriments?.isEmpty() == false;

  /// Old `nutriments` weights are in grams.
  static Unit _oldUnit(Nutrient nutrient) =>
      nutrient.typicalUnit == Unit.MILLI_G ||
          nutrient.typicalUnit == Unit.MICRO_G
      ? Unit.G
      : nutrient.typicalUnit;

  static NutritionValue? _getValue(
    NutritionSet set,
    Nutrient nutrient, {
    required bool needsScaling,
  }) {
    final NutritionValue? nutritionValue = set.nutritionValues?[nutrient];
    final num? value =
        num.tryParse(nutritionValue?.getCleanString() ?? '') ??
        nutritionValue?.valueComputed;
    final Unit? unit = nutritionValue?.unit;
    if (value == null || unit == null) {
      return null;
    }
    // Percentages are the same for every quantity.
    if (!needsScaling || unit == Unit.PERCENT || unit == Unit.PERCENT_VOL) {
      return NutritionValue(value: value, unit: unit);
    }
    // Same threshold as the server: no scaling from a serving below 5 g or ml.
    final num? quantity = set.key.perQuantity;
    if (quantity == null ||
        quantity < 5 ||
        (set.key.perUnit != Unit.G && set.key.perUnit != Unit.MILLI_L)) {
      return null;
    }
    return NutritionValue(value: value * 100 / quantity, unit: unit);
  }
}
