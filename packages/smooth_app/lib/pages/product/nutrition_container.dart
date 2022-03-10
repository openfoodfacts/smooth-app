import 'package:openfoodfacts/interface/JsonObject.dart';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:openfoodfacts/model/OrderedNutrient.dart';
import 'package:openfoodfacts/model/OrderedNutrients.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/UnitHelper.dart';

/// Nutrition data, for nutrient order and conversions.
class NutritionContainer {
  NutritionContainer({
    required final OrderedNutrients orderedNutrients,
    required final Product product,
  }) {
    _loadNutrients(orderedNutrients.nutrients);
    final Map<String, dynamic>? json = product.nutriments?.toJson();
    if (json != null) {
      _loadUnits(json);
      _loadValues(json);
    }
    _servingSize = product.servingSize;
    _barcode = product.barcode!;
  }

  static const String _energyId = 'energy';

  /// special case: present id [OrderedNutrient] but not in [Nutriments] map.
  static const String _energyKJId = 'energy-kj';
  static const String _energyKCalId = 'energy-kcal';
  static const String fakeNutrientIdServingSize = '_servingSize';

  static const Map<Unit, Unit> _nextWeightUnits = <Unit, Unit>{
    Unit.G: Unit.MILLI_G,
    Unit.MILLI_G: Unit.MICRO_G,
    Unit.MICRO_G: Unit.G,
  };

  // For the moment we only care about "weight or not weight?"
  // Could be refined with values taken from https://static.openfoodfacts.org/data/taxonomies/nutrients.json
  // Fun fact: most of them are not supported (yet) by [Nutriments].
  static const Map<String, Unit> _defaultNotWeightUnits = <String, Unit>{
    _energyId: Unit.KJ,
    _energyKCalId: Unit.KCAL,
    'alcohol': Unit.PERCENT,
    'cocoa': Unit.PERCENT,
    'collagen-meat-protein-ratio': Unit.PERCENT,
    'fruits-vegetables-nuts': Unit.PERCENT,
    'fruits-vegetables-nuts-dried': Unit.PERCENT,
    'fruits-vegetables-nuts-estimate': Unit.PERCENT,
  };

  /// All the nutrients (country-related).
  final List<OrderedNutrient> _nutrients = <OrderedNutrient>[];

  /// Nutrient values for 100g and serving.
  final Map<String, double> _values = <String, double>{};

  /// Nutrient units.
  final Map<String, Unit> _units = <String, Unit>{};

  /// Nutrient Ids added by the end-user
  final Set<String> _added = <String>{};

  String? _servingSize;

  String? get servingSize => _servingSize;

  late final String _barcode;

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
    final String nutrientId = orderedNutrient.id;
    final double? value100g = getValue(getValueKey(nutrientId, false));
    final double? valueServing = getValue(getValueKey(nutrientId, true));
    return value100g == null &&
        valueServing == null &&
        (!orderedNutrient.important) &&
        (!_added.contains(nutrientId));
  }

  /// Returns a [Product] with only nutrients data.
  Product getProduct() => Product(
        barcode: _barcode,
        nutriments: _getNutriments(),
        servingSize: _servingSize,
      );

  /// Converts all the data to a [Nutriments].
  Nutriments _getNutriments() {
    /// Converts a (weight) value to grams (before sending a value to the BE)
    double? _convertWeightToG(final double? value, final Unit unit) {
      if (value == null) {
        return null;
      }
      if (unit == Unit.MILLI_G) {
        return value / 1E3;
      }
      if (unit == Unit.MICRO_G) {
        return value / 1E6;
      }
      return value;
    }

    final Map<String, dynamic> map = <String, dynamic>{};
    for (final OrderedNutrient orderedNutrient in getDisplayableNutrients()) {
      final String nutrientId = orderedNutrient.id;
      final String key100g = getValueKey(nutrientId, false);
      final String keyServing = getValueKey(nutrientId, true);
      final double? value100g = getValue(key100g);
      final double? valueServing = getValue(keyServing);
      if (value100g == null && valueServing == null) {
        continue;
      }
      final Unit unit = getUnit(nutrientId);
      if (value100g != null) {
        map[key100g] = _convertWeightToG(value100g, unit);
      }
      if (valueServing != null) {
        //map[keyServing] = _convertWeightToG(valueServing, unit);
      }
      map[_getNutrimentsUnitKey(nutrientId)] = UnitHelper.unitToString(unit);
    }

    return Nutriments.fromJson(map);
  }

  /// Returns the stored product nutrient's value.
  double? getValue(final String valueKey) => _values[valueKey];

  /// Stores the text from the end-user input.
  void setControllerText(final String controllerKey, final String text) {
    if (controllerKey == fakeNutrientIdServingSize) {
      _servingSize = text.trim().isEmpty ? null : text;
      return;
    }

    double? value;
    if (text.isNotEmpty) {
      try {
        value = double.parse(text.replaceAll(',', '.'));
      } catch (e) {
        //
      }
    }
    if (value == null) {
      _values.remove(controllerKey);
    } else {
      _values[controllerKey] = value;
    }
  }

  /// Typical use-case: should we make the [Unit] button clickable?
  static bool isEditableWeight(final OrderedNutrient orderedNutrient) =>
      _getDefaultUnit(orderedNutrient.id) == null;

  /// Typical use-case: [Unit] button action.
  void setNextWeightUnit(final OrderedNutrient orderedNutrient) {
    final Unit unit = getUnit(orderedNutrient.id);
    _setUnit(orderedNutrient.id, _nextWeightUnits[unit] ?? unit);
  }

  /// Returns the nutrient [Unit], after possible alterations.
  Unit getUnit(String nutrientId) {
    nutrientId = _fixNutrientId(nutrientId);
    switch (nutrientId) {
      case _energyId:
      case _energyKJId:
        return Unit.KJ;
      case _energyKCalId:
        return Unit.KCAL;
      default:
        return _units[nutrientId] ?? _getDefaultUnit(nutrientId) ?? Unit.G;
    }
  }

  /// Stores the nutrient [Unit].
  void _setUnit(final String nutrientId, final Unit unit) =>
      _units[_fixNutrientId(nutrientId)] = unit;

  static Unit? _getDefaultUnit(final String nutrientId) =>
      _defaultNotWeightUnits[_fixNutrientId(nutrientId)];

  /// To be used when an [OrderedNutrient] is added to the input list
  void add(final OrderedNutrient orderedNutrient) =>
      _added.add(orderedNutrient.id);

  /// Returns the [Nutriments] map key for the nutrient value.
  ///
  /// * [perServing] true: per serving.
  /// * [perServing] false: per 100g.
  static String getValueKey(
    String nutrientId,
    final bool perServing,
  ) {
    nutrientId = _fixNutrientId(nutrientId);
    // 'energy-kcal' is directly for serving (no 'energy-kcal_serving')
    if (nutrientId == _energyKCalId && perServing) {
      return _energyKCalId;
    }
    return '$nutrientId${perServing ? '_serving' : '_100g'}';
  }

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
    void _populateOrderedNutrientList(final List<OrderedNutrient> list) {
      for (final OrderedNutrient nutrient in list) {
        if (nutrient.id != _energyKJId &&
            !Nutriments.supportedNutrientIds.contains(nutrient.id)) {
          continue;
        }
        final bool nowEnergy =
            nutrient.id == _energyId || nutrient.id == _energyKJId;
        bool addNutrient = true;
        if (nowEnergy) {
          if (alreadyEnergyKJ) {
            addNutrient = false;
          }
          alreadyEnergyKJ = true;
        }
        if (addNutrient) {
          _nutrients.add(nutrient);
        }
        if (nutrient.subNutrients != null) {
          _populateOrderedNutrientList(nutrient.subNutrients!);
        }
      }
    }

    _populateOrderedNutrientList(nutrients);

    if (!alreadyEnergyKJ) {
      throw Exception('no energy or energyKJ found: very suspicious!');
    }
  }

  /// Returns the unit key according to [Nutriments] json map.
  static String _getNutrimentsUnitKey(final String nutrientId) =>
      '${_fixNutrientId(nutrientId)}_unit';

  static String _fixNutrientId(final String nutrientId) =>
      nutrientId == _energyKJId ? _energyId : nutrientId;

  /// Loads product nutrient units into a map.
  ///
  /// Needs nutrients to be loaded first.
  void _loadUnits(final Map<String, dynamic> json) {
    for (final OrderedNutrient orderedNutrient in _nutrients) {
      final String nutrientId = orderedNutrient.id;
      final String unitKey = _getNutrimentsUnitKey(nutrientId);
      final dynamic value = json[unitKey];
      if (value == null || value is! String) {
        continue;
      }
      final Unit? unit = UnitHelper.stringToUnit(value);
      if (unit != null) {
        _setUnit(nutrientId, unit);
      }
    }
  }

  /// Loads product nutrients into a map.
  ///
  /// Needs nutrients and units to be loaded first.
  void _loadValues(final Map<String, dynamic> json) {
    /// Converts a double (weight) value from grams.
    ///
    /// Typical use-case: after receiving a value from the BE.
    double? _convertWeightFromG(final double? value, final Unit unit) {
      if (value == null) {
        return null;
      }
      if (unit == Unit.MILLI_G) {
        return value * 1E3;
      }
      if (unit == Unit.MICRO_G) {
        return value * 1E6;
      }
      return value;
    }

    for (final OrderedNutrient orderedNutrient in _nutrients) {
      final String nutrientId = orderedNutrient.id;
      final Unit unit = getUnit(nutrientId);
      for (int i = 0; i < 2; i++) {
        final bool perServing = i == 0;
        final String valueKey = getValueKey(nutrientId, perServing);
        final double? value = _convertWeightFromG(
          JsonObject.parseDouble(json[valueKey]),
          unit,
        );
        if (value != null) {
          _values[valueKey] = value;
        }
      }
    }
  }
}
