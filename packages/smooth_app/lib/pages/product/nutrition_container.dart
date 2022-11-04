import 'package:intl/intl.dart';
import 'package:openfoodfacts/model/Nutrient.dart';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:openfoodfacts/model/OrderedNutrient.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/model/PerSize.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/UnitHelper.dart';

/// Nutrition data, for nutrient order and conversions.
class NutritionContainer {
  NutritionContainer({
    required final OrderedNutrients orderedNutrients,
    required final Product product,
  }) {
    _initialPerSize = perSize =
        PerSize.fromOffTag(product.nutrimentDataPer) ?? PerSize.oneHundredGrams;
    _loadNutrients(orderedNutrients.nutrients);
    _loadUnits();
    if (product.nutriments != null) {
      _loadValues(product.nutriments!);
    }
    setServingText(product.servingSize);
    _initialNoNutritionData =
        noNutritionData = product.noNutritionData ?? false;
  }

  /// Returns the [Nutrient] that matches the [orderedNutrient].
  ///
  /// Special case: energy is considered as energyKJ
  static Nutrient? getNutrient(final OrderedNutrient orderedNutrient) {
    if (orderedNutrient.id == 'energy') {
      return Nutrient.energyKJ;
    }
    return orderedNutrient.nutrient;
  }

  static const Map<Unit, Unit> _nextWeightUnits = <Unit, Unit>{
    Unit.G: Unit.MILLI_G,
    Unit.MILLI_G: Unit.MICRO_G,
    Unit.MICRO_G: Unit.G,
  };

  /// All the nutrients (country-related) that do match [Nutrient]s.
  final List<OrderedNutrient> _nutrients = <OrderedNutrient>[];

  /// Nutrient values.
  final Map<Nutrient, double?> _values = <Nutrient, double?>{};

  /// Nutrient units.
  final Map<Nutrient, Unit> _units = <Nutrient, Unit>{};

  /// Initial nutrient units.
  final Map<Nutrient, Unit> _initialUnits = <Nutrient, Unit>{};

  /// Nutrients added by the end-user.
  final Set<Nutrient> _added = <Nutrient>{};

  late String servingSize;

  late bool noNutritionData;
  late bool _initialNoNutritionData;

  late PerSize perSize;
  late PerSize _initialPerSize;

  /// Returns the not interesting nutrients, for a "Please add me!" list.
  Iterable<OrderedNutrient> getLeftoverNutrients() => _nutrients.where(
        (final OrderedNutrient element) => _isNotRelevant(element),
      );

  /// Returns the interesting nutrients that need to be displayed.
  Iterable<OrderedNutrient> getDisplayableNutrients() => _nutrients.where(
        (final OrderedNutrient element) => !_isNotRelevant(element),
      );

  /// Returns true if the [OrderedNutrient] is not relevant.
  bool _isNotRelevant(final OrderedNutrient orderedNutrient) {
    final Nutrient nutrient = getNutrient(orderedNutrient)!;
    return getValue(nutrient) == null &&
        (!orderedNutrient.important) &&
        (!_added.contains(nutrient));
  }

  /// Converts all the data to a [Nutriments].
  Nutriments _getNutriments() {
    final Nutriments nutriments = Nutriments.empty();
    for (final MapEntry<Nutrient, double?> entry in _values.entries) {
      final Nutrient nutrient = entry.key;
      final double? value = entry.value;
      nutriments.setValue(
        nutrient,
        perSize,
        convertWeightToG(value, getUnit(nutrient)),
      );
    }
    return nutriments;
  }

  /// Returns the stored product nutrient's value.
  double? getValue(final Nutrient nutrient) => _values[nutrient];

  /// Stores the text from the end-user input.
  void setNutrientValueText(
    final Nutrient nutrient,
    final String? text,
    final NumberFormat numberFormat,
  ) {
    num? value;
    if (text?.isNotEmpty == true) {
      try {
        value = numberFormat.parse(text!);
      } catch (e) {
        //
      }
    }
    _values[nutrient] = value?.toDouble();
  }

  /// Stores the text from the end-user input.
  void setServingText(final String? text) =>
      servingSize = text?.trim().isNotEmpty == true ? text! : '';

  /// Typical use-case: should we make the [Unit] button clickable?
  bool isEditableWeight(final Unit unit) => _nextWeightUnits[unit] != null;

  /// Typical use-case: [Unit] button action.
  void setNextWeightUnit(final OrderedNutrient orderedNutrient) {
    final Nutrient nutrient = orderedNutrient.nutrient!;
    final Unit unit = getUnit(nutrient);
    _setUnit(nutrient, _nextWeightUnits[unit] ?? unit, init: false);
  }

  /// Returns the nutrient [Unit].
  Unit getUnit(final Nutrient nutrient) => _units[nutrient]!;

  /// Stores the nutrient [Unit].
  void _setUnit(
    final Nutrient nutrient,
    final Unit unit, {
    required final bool init,
  }) {
    _units[nutrient] = unit;
    if (init) {
      _initialUnits[nutrient] = unit;
    }
  }

  /// To be used when an [OrderedNutrient] is added to the input list
  void add(final OrderedNutrient orderedNutrient) =>
      _added.add(getNutrient(orderedNutrient)!);

  /// Returns a vertical list of nutrients from a tree structure.
  ///
  /// Typical use-case: to be used from BE's tree nutrients in order to get
  /// a simple one-dimension list, easier to display and parse.
  /// For some countries, there's energy or energyKJ, or both
  /// cf. https://github.com/openfoodfacts/openfoodfacts-server/blob/main/lib/ProductOpener/Food.pm
  /// Regarding our list of nutrients here, we need one and only one of them.
  void _loadNutrients(
    final List<OrderedNutrient> nutrients,
  ) {
    bool alreadyEnergyKJ = false;

    // inner method, in order to use alreadyEnergyKJ without a private variable.
    void populateOrderedNutrientList(final List<OrderedNutrient> list) {
      for (final OrderedNutrient orderedNutrient in list) {
        final Nutrient? nutrient = getNutrient(orderedNutrient);
        if (nutrient != null) {
          bool addNutrient = true;
          if (nutrient == Nutrient.energyKJ) {
            if (alreadyEnergyKJ) {
              addNutrient = false;
            }
            alreadyEnergyKJ = true;
          }
          if (addNutrient) {
            _nutrients.add(orderedNutrient);
          }
        }
        if (orderedNutrient.subNutrients != null) {
          populateOrderedNutrientList(orderedNutrient.subNutrients!);
        }
      }
    }

    populateOrderedNutrientList(nutrients);

    if (!alreadyEnergyKJ) {
      throw Exception('no energy or energyKJ found: very suspicious!');
    }
  }

  /// Converts a double (weight) value from grams.
  ///
  /// Typical use-case: after receiving a value from the BE.
  static double? convertWeightFromG(final double? value, final Unit unit) {
    if (value == null) {
      return null;
    }
    final double? factor = _conversionFactorFromG[unit];
    if (factor != null) {
      return value * factor;
    }
    return value;
  }

  /// Converts a double (weight) value from grams.
  ///
  /// Typical use-case: sending a value to the BE.
  static double? convertWeightToG(final double? value, final Unit unit) {
    if (value == null) {
      return null;
    }
    final double? factor = _conversionFactorFromG[unit];
    if (factor != null) {
      return value / factor;
    }
    return value;
  }

  /// Conversion factors of a value in [Unit] to [Unit.G].
  static const Map<Unit, double> _conversionFactorFromG = <Unit, double>{
    Unit.MILLI_G: 1E3,
    Unit.MICRO_G: 1E6,
  };

  /// Loads product nutrient units into a map.
  ///
  /// Needs nutrients to be loaded first.
  void _loadUnits() {
    for (final OrderedNutrient orderedNutrient in _nutrients) {
      final Nutrient nutrient = getNutrient(orderedNutrient)!;
      _setUnit(nutrient, nutrient.typicalUnit, init: true);
    }
  }

  /// Loads product nutrients into a map.
  ///
  /// Needs nutrients and units to be loaded first.
  void _loadValues(final Nutriments nutriments) {
    for (final OrderedNutrient orderedNutrient in _nutrients) {
      final Nutrient nutrient = getNutrient(orderedNutrient)!;
      final Unit unit = getUnit(nutrient);
      final double? value = convertWeightFromG(
        nutrient == Nutrient.energyKJ
            ? nutriments.getComputedKJ(perSize)?.roundToDouble()
            : nutriments.getValue(nutrient, perSize),
        unit,
      );
      if (value != null) {
        _values[nutrient] = value;
      }
    }
  }

  /// Returns true if the user edited something.
  bool isEdited() {
    if (noNutritionData != _initialNoNutritionData) {
      return true;
    }
    if (perSize != _initialPerSize) {
      return true;
    }
    for (final Nutrient nutrient in _units.keys) {
      if (_initialUnits[nutrient] != _units[nutrient]) {
        return true;
      }
    }
    return false;
  }

  /// Returns a [Product] with changed nutrients data.
  Product getChangedProduct(Product product) {
    product.noNutritionData = noNutritionData;
    product.nutrimentDataPer = perSize.offTag;
    product.nutriments = _getNutriments();
    product.servingSize = servingSize;
    return product;
  }
}
