import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';

extension ProductNutritionExtension on Product {
  /// Returns the as sold value of [nutrient] for [perSize] (weights in grams),
  /// or null if unknown.
  ///
  /// Same priority as the server: manufacturer values first, then packaging
  /// values. Per 100g also takes a per 100ml value, or a per serving value
  /// scaled to 100.
  double? getNutrientValue(Nutrient nutrient, PerSize perSize) {
    final List<PerSize> perSizes = <PerSize>[
      perSize,
      if (perSize == PerSize.oneHundredGrams) ...<PerSize>[
        PerSize.oneHundredMilliliters,
        PerSize.serving,
      ],
    ];
    for (final NutritionSet set in _getAsSoldInputSets()) {
      if (!perSizes.contains(set.key.perSize)) {
        continue;
      }
      final NutritionValue? nutritionValue = set.nutritionValues?[nutrient];
      final num? value = num.tryParse(nutritionValue?.getCleanString() ?? '');
      final Unit? unit = nutritionValue?.unit;
      if (value == null || unit == null) {
        continue;
      }
      final double? grams = NutritionContainerHelper.convertWeightToG(
        value.toDouble(),
        unit,
      );
      if (set.key.perSize != PerSize.serving || perSize == PerSize.serving) {
        return grams;
      }
      final double? servingFactor = _getServingTo100Factor(set.key);
      if (servingFactor != null && grams != null) {
        return grams * servingFactor;
      }
    }
    return null;
  }

  bool get hasNutritionData =>
      (NutritionHelper().getInputSets(this) ?? <NutritionSet>[]).any(
        (NutritionSet set) =>
            set.key.preparation == NutritionSetKey.preparationAsSold &&
            set.key.source != NutritionSetKey.sourceEstimate &&
            set.nutritionValues?.isNotEmpty == true,
      );

  List<NutritionSet> _getAsSoldInputSets() {
    final List<NutritionSet> sets =
        NutritionHelper().getInputSets(this) ?? <NutritionSet>[];
    return <NutritionSet>[
      for (final String source in <String>[
        NutritionSetKey.sourceManufacturer,
        NutritionSetKey.sourcePackaging,
      ])
        for (final PerSize perSize in <PerSize>[
          PerSize.oneHundredGrams,
          PerSize.oneHundredMilliliters,
          PerSize.serving,
        ])
          ...sets.where(
            (NutritionSet set) =>
                set.key.source == source &&
                set.key.perSize == perSize &&
                set.key.preparation == NutritionSetKey.preparationAsSold,
          ),
    ];
  }

  /// Same threshold as the server: no scaling from a serving below 5 g or ml.
  static double? _getServingTo100Factor(NutritionSetKey key) {
    final num? quantity = key.perQuantity;
    if (quantity == null ||
        quantity < 5 ||
        (key.perUnit != Unit.G && key.perUnit != Unit.MILLI_L)) {
      return null;
    }
    return 100 / quantity;
  }
}
