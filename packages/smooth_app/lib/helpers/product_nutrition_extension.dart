import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';

extension ProductNutritionExtension on Product {
  /// Returns the as sold value of [nutrient] for [perSize] (weights in grams),
  /// or null if unknown.
  ///
  /// Same priority as the server: manufacturer, packaging, then usda values.
  /// Per 100g also takes a per 100ml value, or a per serving value scaled to
  /// 100. Energy in kJ is computed from kcal when missing.
  double? getNutrientValue(Nutrient nutrient, PerSize perSize) =>
      _getStoredValue(nutrient, perSize) ??
      (nutrient == Nutrient.energyKJ
          ? NutritionContainerHelper.getKJFromKCal(
              _getStoredValue(Nutrient.energyKCal, perSize),
            )
          : null);

  double? _getStoredValue(Nutrient nutrient, PerSize perSize) {
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
          final double? value = _getValue(
            set,
            nutrient,
            needsScaling:
                setPerSize == PerSize.serving && perSize != PerSize.serving,
          );
          if (value != null) {
            return value;
          }
        }
      }
    }
    return null;
  }

  bool get hasNutritionData =>
      (NutritionHelper().getInputSets(this) ?? <NutritionSet>[]).any(
        (NutritionSet set) =>
            _sources.contains(set.key.source) &&
            set.key.preparation == NutritionSetKey.preparationAsSold &&
            set.nutritionValues?.isNotEmpty == true,
      );

  static const List<String> _sources = <String>[
    NutritionSetKey.sourceManufacturer,
    NutritionSetKey.sourcePackaging,
    'usda',
  ];

  static double? _getValue(
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
    final double? grams = NutritionContainerHelper.convertWeightToG(
      value.toDouble(),
      unit,
    );
    // Percentages are the same for every quantity.
    if (!needsScaling || unit == Unit.PERCENT || unit == Unit.PERCENT_VOL) {
      return grams;
    }
    // Same threshold as the server: no scaling from a serving below 5 g or ml.
    final num? quantity = set.key.perQuantity;
    if (grams == null ||
        quantity == null ||
        quantity < 5 ||
        (set.key.perUnit != Unit.G && set.key.perUnit != Unit.MILLI_L)) {
      return null;
    }
    return grams * 100 / quantity;
  }
}
