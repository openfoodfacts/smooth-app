import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Helper class that computes the values of each nutrient for a portion.
class PortionHelper {
  PortionHelper(
    final List<OrderedNutrient> localizedNutrients,
    this.productNutriments,
    this.grams,
  ) {
    _numberFormat = NumberFormat('####0.###', ProductQuery.getLocaleString());
    _populateFactoredNutrients(localizedNutrients);
  }

  final Nutriments productNutriments;

  /// Size of the portion, in grams.
  final int grams;

  /// Results in a table: 1 nutrient 1 row, 1 row 2 columns (name, quantity).
  final List<List<String>> _table = <List<String>>[];

  /// Localized number formatter.
  late final NumberFormat _numberFormat;

  /// Have we already process energy or energyKJ? (redundant data)
  bool _alreadyEnergyKJ = false;

  /// True if no result computed at all.
  bool get isEmpty => _table.isEmpty;

  /// Number of successfully computed nutrients.
  int get length => _table.length;

  /// Localized name of the [index]th nutrient.
  String getName(final int index) => _table[index][0];

  /// Value + unit of the [index]th nutrient.
  String getValue(final int index) => _table[index][1];

  /// Recursively populates nutrients' portion values.
  void _populateFactoredNutrients(
    final List<OrderedNutrient> orderedNutrients,
  ) {
    for (final OrderedNutrient orderedNutrient in orderedNutrients) {
      final Nutrient? nutrient =
          NutritionContainerHelper.getNutrient(orderedNutrient);
      if (nutrient != null) {
        if (orderedNutrient.name != null) {
          try {
            _populateFactoredNutrient(nutrient, orderedNutrient.name!);
          } catch (e) {
            // just ignore
          }
        }
      }
      if (orderedNutrient.subNutrients != null) {
        _populateFactoredNutrients(orderedNutrient.subNutrients!);
      }
    }
  }

  /// Populates for a single nutrient the portion value.
  void _populateFactoredNutrient(
    final Nutrient nutrient,
    final String nutrientName,
  ) {
    double? value =
        productNutriments.getValue(nutrient, PerSize.oneHundredGrams);
    if (value == null) {
      return;
    }
    final Unit unit = nutrient.typicalUnit;
    value = NutritionContainerHelper.convertWeightFromG(value, unit);
    if (unit != Unit.PERCENT) {
      // Percents are not impacted by the portion size
      value = value! * grams / 100;
    }
    if (nutrient == Nutrient.energyKJ) {
      // Redundant data with energyKJ and energy: one is enough (the first one).
      if (_alreadyEnergyKJ) {
        return;
      }
      _alreadyEnergyKJ = true;
    }
    _table.add(
      <String>[
        nutrientName,
        '${_numberFormat.format(value)} ${_unitStandardSpellings[unit] ?? ''}'
      ],
    );
  }

  /// [Unit] standard spellings.
  static const Map<Unit, String> _unitStandardSpellings = <Unit, String>{
    Unit.KCAL: 'kcal',
    Unit.KJ: 'kj',
    Unit.G: 'g',
    Unit.MILLI_G: 'mg',
    Unit.MICRO_G: 'μg',
    Unit.MILLI_L: 'ml',
    Unit.L: 'l',
    Unit.PERCENT: '%',
  };
}
