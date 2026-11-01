import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Nutrition data, for nutrient order and conversions.
class NutritionContainerHelper extends ChangeNotifier {
  NutritionContainerHelper({
    required OrderedNutrients orderedNutrients,
    required Product product,
  }) {
    _loadNutrients(orderedNutrients.nutrients);
    _loadValues(product);
    _perSize = _values[PerSize.oneHundredGrams]!.isEmpty
        ? (_values[PerSize.serving]!.isEmpty
              ? PerSize.oneHundredGrams
              : PerSize.serving)
        : PerSize.oneHundredGrams;
    setServingText(product.servingSize);
    _initialServingSize = servingSize;
    _initialNoNutritionData = _noNutritionData =
        product.noNutritionData ??
        NutritionHelper().getNoNutritionDataOnPackaging(product) ??
        false;
  }

  /// Returns the [Nutrient] that matches the [orderedNutrient].
  ///
  /// Special case: energy is considered as energyKJ
  static Nutrient? getNutrient(OrderedNutrient orderedNutrient) {
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

  List<OrderedNutrient> get allNutrients => _nutrients;

  static const List<PerSize> _lines = <PerSize>[
    PerSize.oneHundredGrams,
    PerSize.serving,
  ];

  /// Set key of the "per 100g" line: it is "per 100ml" for some products.
  PerSize _hundredPerSize = PerSize.oneHundredGrams;

  final Map<PerSize, Map<Nutrient, num>> _values =
      <PerSize, Map<Nutrient, num>>{
        for (final PerSize line in _lines) line: <Nutrient, num>{},
      };

  /// Values typed by the end-user and different from the loaded ones.
  ///
  /// A null value means that the end-user cleared the nutrient.
  final Map<PerSize, Map<Nutrient, num?>> _edited =
      <PerSize, Map<Nutrient, num?>>{
        for (final PerSize line in _lines) line: <Nutrient, num?>{},
      };

  final Map<PerSize, Map<Nutrient, Unit>> _units =
      <PerSize, Map<Nutrient, Unit>>{
        for (final PerSize line in _lines) line: <Nutrient, Unit>{},
      };

  final Map<PerSize, Map<Nutrient, Unit>> _initialUnits =
      <PerSize, Map<Nutrient, Unit>>{
        for (final PerSize line in _lines) line: <Nutrient, Unit>{},
      };

  /// Nutrients added by the end-user.
  final Set<Nutrient> _added = <Nutrient>{};

  late String servingSize;
  late String _initialServingSize;

  late bool _noNutritionData;
  late bool _initialNoNutritionData;

  bool get noNutritionData => _noNutritionData;

  set noNutritionData(bool value) {
    _noNutritionData = value;
    notifyListeners();
  }

  /// The line currently displayed.
  late PerSize _perSize;
  PerSize get perSize => _perSize;

  set perSize(PerSize value) {
    _perSize = value;
    notifyListeners();
  }

  bool _loadingRobotoffExtraction = false;

  bool get loadingRobotoffExtraction => _loadingRobotoffExtraction;

  RobotoffNutrientExtractionResult? _robotoffNutrientExtraction;

  RobotoffNutrientExtractionResult? get robotoffNutrientExtraction =>
      _robotoffNutrientExtraction;

  // Fetch the robotoff extraction for the product, return true if the extraction was successful
  Future<bool> fetchRobotoffExtraction(Product product) async {
    if (product.barcode == null) {
      return false;
    }

    _loadingRobotoffExtraction = true;
    _robotoffNutrientExtraction = null;
    notifyListeners();

    final RobotoffNutrientExtractionResult extractionResult =
        await RobotoffAPIClient.getNutrientExtraction(
          product.barcode!,
          uriHelper: ProductQuery.uriRobotoffHelper,
        );

    final bool extractionSuccessful = extractionResult.status == 'found';

    if (extractionSuccessful) {
      // When using Robotoff extraction we enforce the perSize to 100g
      perSize = PerSize.oneHundredGrams;

      Set<String> extractedNutrients =
          extractionResult.latestInsight?.data?.nutrients?.keys.toSet() ??
          <String>{};

      extractedNutrients = extractedNutrients
          .where((String nutrient) => !nutrient.contains('_serving'))
          .map((String key) => key.replaceAll('_100g', ''))
          .toSet();

      for (final String nutrientOffTag in extractedNutrients) {
        // If the nutrient is not in the list of nutrients, we add it
        final OrderedNutrient? missingNutrient = getLeftoverNutrients()
            .firstWhereOrNull((OrderedNutrient orderedNutrient) {
              return orderedNutrient.nutrient?.offTag == nutrientOffTag;
            });

        if (missingNutrient != null) {
          add(missingNutrient);
        }
      }

      for (final OrderedNutrient orderedNutrient in _nutrients) {
        final Nutrient nutrient = getNutrient(orderedNutrient)!;
        final RobotoffNutrientEntity? robotoffNutrientEntity = extractionResult
            .getNutrientEntity(nutrient, perSize);
        if (robotoffNutrientEntity != null) {
          AnalyticsHelper.trackRobotoffExtraction(
            AnalyticsRobotoffEvents.robotoffNutritionExtracted,
            nutrient,
            product,
          );
        }
      }

      _robotoffNutrientExtraction = extractionResult;
    }

    _loadingRobotoffExtraction = false;
    notifyListeners();

    return extractionSuccessful;
  }

  /// Returns the not interesting nutrients, for a "Please add me!" list.
  Iterable<OrderedNutrient> getLeftoverNutrients() => _nutrients.where(
    (OrderedNutrient element) => _isNotRelevant(element),
  );

  /// Returns the interesting nutrients that need to be displayed.
  Iterable<OrderedNutrient> getDisplayableNutrients() => _nutrients.where(
    (OrderedNutrient element) => !_isNotRelevant(element),
  );

  /// Returns true if the [OrderedNutrient] is not relevant.
  bool _isNotRelevant(OrderedNutrient orderedNutrient) {
    final Nutrient nutrient = getNutrient(orderedNutrient)!;
    return getValue(nutrient) == null &&
        (!orderedNutrient.displayInEditForm) &&
        (!_added.contains(nutrient));
  }

  /// Returns the stored product nutrient's value.
  num? getValue(final Nutrient nutrient) => _values[_perSize]![nutrient];

  /// Stores the end-user input when it differs from the loaded value.
  void setNutrientValueText(
    final PerSize perSize,
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
    final num? loaded = _values[perSize]![nutrient];
    final bool unchanged = value == null || loaded == null
        ? value == loaded
        : numberFormat.format(value) == numberFormat.format(loaded);
    if (unchanged) {
      _edited[perSize]!.remove(nutrient);
    } else {
      _edited[perSize]![nutrient] = value;
    }
  }

  /// Stores the text from the end-user input.
  void setServingText(String? text) =>
      servingSize = text?.trim().isNotEmpty == true ? text! : '';

  /// Typical use-case: should we make the [Unit] button clickable?
  bool isEditableWeight(Unit unit) => _nextWeightUnits[unit] != null;

  /// Typical use-case: [Unit] button action.
  void setNextWeightUnit(OrderedNutrient orderedNutrient) {
    final Nutrient nutrient = orderedNutrient.nutrient!;
    final Unit unit = getUnit(nutrient);
    setNutrientUnit(nutrient, _nextWeightUnits[unit] ?? unit);
  }

  List<Unit> getUnits(Nutrient nutrient) {
    final List<Unit> units = <Unit>[Unit.G, Unit.MILLI_G, Unit.MICRO_G];

    if (units.contains(getUnit(nutrient))) {
      return units;
    } else {
      return <Unit>[];
    }
  }

  /// Returns the nutrient [Unit].
  Unit getUnit(final Nutrient nutrient) => _units[_perSize]![nutrient]!;

  /// Stores the nutrient [Unit].
  void setNutrientUnit(final Nutrient nutrient, final Unit unit) =>
      _units[_perSize]![nutrient] = unit;

  /// To be used when an [OrderedNutrient] is added to the input list
  void add(OrderedNutrient orderedNutrient) =>
      _added.add(getNutrient(orderedNutrient)!);

  /// Returns a vertical list of nutrients from a tree structure.
  ///
  /// Typical use-case: to be used from BE's tree nutrients in order to get
  /// a simple one-dimension list, easier to display and parse.
  /// For some countries, there's energy or energyKJ, or both
  /// cf. https://github.com/openfoodfacts/openfoodfacts-server/blob/main/lib/ProductOpener/Food.pm
  /// Regarding our list of nutrients here, we need one and only one of them.
  void _loadNutrients(List<OrderedNutrient> nutrients) {
    bool alreadyEnergyKJ = false;

    // inner method, in order to use alreadyEnergyKJ without a private variable.
    void populateOrderedNutrientList(List<OrderedNutrient> list) {
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
  static double? convertWeightFromG(double? value, Unit unit) {
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
  static double? convertWeightToG(double? value, Unit unit) {
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

  /// Loads the values and units of the as sold nutrition, line by line.
  ///
  /// Each value is the packaging one, else the manufacturer one. Estimates and
  /// prepared sets are ignored. Needs nutrients to be loaded first.
  void _loadValues(final Product product) {
    final NutritionHelper helper = NutritionHelper();
    final List<NutritionSet> inputSets =
        helper.getInputSets(product) ?? <NutritionSet>[];

    NutritionSet? getSet(final String source, final PerSize perSize) =>
        helper.getNutritionSet(
          inputSets,
          NutritionSetKey(
            source: source,
            preparation: NutritionSetKey.preparationAsSold,
            perSize: perSize,
          ),
        );

    bool hasSets(final PerSize perSize) =>
        getSet(NutritionSetKey.sourcePackaging, perSize) != null ||
        getSet(NutritionSetKey.sourceManufacturer, perSize) != null;

    if (!hasSets(PerSize.oneHundredGrams) &&
        hasSets(PerSize.oneHundredMilliliters)) {
      _hundredPerSize = PerSize.oneHundredMilliliters;
    }

    for (final PerSize line in _lines) {
      final PerSize perSize = line == PerSize.serving
          ? PerSize.serving
          : _hundredPerSize;
      final List<NutritionSet?> sets = <NutritionSet?>[
        getSet(NutritionSetKey.sourcePackaging, perSize),
        getSet(NutritionSetKey.sourceManufacturer, perSize),
      ];

      NutritionValue? find(final Nutrient nutrient) {
        for (final NutritionSet? set in sets) {
          final NutritionValue? value = set?.nutritionValues?[nutrient];
          if (value != null) {
            return value;
          }
        }
        return null;
      }

      num? getNumber(final NutritionValue? value) =>
          num.tryParse(value?.getCleanString() ?? '');

      for (final OrderedNutrient orderedNutrient in _nutrients) {
        final Nutrient nutrient = getNutrient(orderedNutrient)!;
        final NutritionValue? nutritionValue = find(nutrient);
        num? value = getNumber(nutritionValue);
        if (value == null && nutrient == Nutrient.energyKJ) {
          final num? kcal = getNumber(find(Nutrient.energyKCal));
          if (kcal != null) {
            value = NutrimentsHelper.fromKCalToKJ(
              kcal.toDouble(),
            ).roundToDouble();
          }
        }
        if (value != null) {
          _values[line]![nutrient] = value;
        }
        final Unit unit = nutritionValue?.unit ?? nutrient.typicalUnit;
        _units[line]![nutrient] = unit;
        _initialUnits[line]![nutrient] = unit;
      }
    }
  }

  /// Returns true if the user edited something.
  bool isEdited() {
    if (_noNutritionData != _initialNoNutritionData) {
      return true;
    }
    for (final PerSize line in _lines) {
      for (final MapEntry<Nutrient, Unit> entry in _units[line]!.entries) {
        if (_initialUnits[line]![entry.key] != entry.value) {
          return true;
        }
      }
    }
    return false;
  }

  /// Plain decimal notation, never an exponent.
  static final NumberFormat _writeFormat = NumberFormat(
    '####0.##########',
    'en',
  );

  /// Returns the packaging nutrition sets with only the changed nutrients.
  List<NutritionSet> _getChangedSets() {
    final List<NutritionSet> result = <NutritionSet>[];
    for (final PerSize line in _lines) {
      final Map<Nutrient, NutritionValue> nutritionValues =
          <Nutrient, NutritionValue>{};
      for (final OrderedNutrient orderedNutrient in _nutrients) {
        final Nutrient nutrient = getNutrient(orderedNutrient)!;
        final num? loaded = _values[line]![nutrient];
        final bool edited = _edited[line]!.containsKey(nutrient);
        final Unit unit = _units[line]![nutrient]!;
        if (!edited && unit == _initialUnits[line]![nutrient]) {
          continue;
        }
        final num? value = edited ? _edited[line]![nutrient] : loaded;
        if (value == null && loaded == null) {
          continue;
        }
        nutritionValues[nutrient] = NutritionValue(
          unit: unit,
          valueString: value == null ? '' : _writeFormat.format(value),
        );
      }
      if (nutritionValues.isNotEmpty) {
        result.add(
          NutritionSet(
            key: NutritionSetKey(
              source: NutritionSetKey.sourcePackaging,
              preparation: NutritionSetKey.preparationAsSold,
              perSize: line == PerSize.serving
                  ? PerSize.serving
                  : _hundredPerSize,
            ),
            nutritionValues: nutritionValues,
          ),
        );
      }
    }
    return result;
  }

  /// Returns the minimal products to save, with only the changed data.
  ///
  /// The "no nutrition data" flag can't be saved in the same request as the
  /// nutrition values, hence a separate product.
  List<Product> getChangedProducts(final String barcode) {
    final List<Product> result = <Product>[];
    final Product values = Product(barcode: barcode);
    final List<NutritionSet> sets = _getChangedSets();
    if (sets.isNotEmpty) {
      NutritionHelper().setInputSets(values, sets);
    }
    if (servingSize != _initialServingSize) {
      values.servingSize = servingSize;
    }
    if (values.nutrition != null || values.servingSize != null) {
      result.add(values);
    }
    if (_noNutritionData != _initialNoNutritionData) {
      result.add(Product(barcode: barcode)..noNutritionData = _noNutritionData);
    }
    return result;
  }
}
