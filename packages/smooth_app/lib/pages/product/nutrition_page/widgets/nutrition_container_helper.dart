import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

/// Nutrition data, for nutrient order and conversions.
class NutritionContainerHelper extends ChangeNotifier {
  NutritionContainerHelper({
    required final OrderedNutrients orderedNutrients,
    required final Product product,
  }) {
    _initialPerSize = _perSize =
        PerSize.fromOffTag(product.nutrimentDataPer) ?? PerSize.oneHundredGrams;
    _loadNutrients(orderedNutrients.nutrients);
    _loadUnits();
    if (product.nutriments != null) {
      _loadValues(product.nutriments!);
    }
    setServingText(product.servingSize);
    _initialNoNutritionData =
        _noNutritionData = product.noNutritionData ?? false;
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

  List<OrderedNutrient> get allNutrients => _nutrients;

  /// Nutrient values.
  final Map<Nutrient, double?> _values = <Nutrient, double?>{};

  /// Nutrient units.
  final Map<Nutrient, Unit> _units = <Nutrient, Unit>{};

  /// Initial nutrient units.
  final Map<Nutrient, Unit> _initialUnits = <Nutrient, Unit>{};

  /// Nutrients added by the end-user.
  final Set<Nutrient> _added = <Nutrient>{};

  late String servingSize;

  late bool _noNutritionData;
  late bool _initialNoNutritionData;

  bool get noNutritionData => _noNutritionData;

  set noNutritionData(final bool value) {
    _noNutritionData = value;
    notifyListeners();
  }

  late PerSize _perSize;
  late PerSize _initialPerSize;
  PerSize get perSize => _perSize;

  set perSize(final PerSize value) {
    _perSize = value;
    notifyListeners();
  }

  bool _loadingRobotoffExtraction = false;

  bool get loadingRobotoffExtraction => _loadingRobotoffExtraction;

  RobotoffNutrientExtractionResult? _robotoffNutrientExtraction;

  RobotoffNutrientExtractionResult? get robotoffNutrientExtraction =>
      _robotoffNutrientExtraction;

  // Fetch the robotoff extraction for the product, return true if the extraction was successful
  Future<bool> fetchRobotoffExtraction(final Product product) async {
    if (product.barcode == null) {
      return false;
    }

    _loadingRobotoffExtraction = true;
    _robotoffNutrientExtraction = null;
    notifyListeners();

    final RobotoffNutrientExtractionResult extractionResult =
        await RobotoffAPIClient.getNutrientExtraction(product.barcode!);

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
        final OrderedNutrient? missingNutrient =
            getLeftoverNutrients().firstWhereOrNull(
          (final OrderedNutrient orderedNutrient) {
            return orderedNutrient.nutrient?.offTag == nutrientOffTag;
          },
        );

        if (missingNutrient != null) {
          add(missingNutrient);
        }
      }

      for (final OrderedNutrient orderedNutrient in _nutrients) {
        final Nutrient nutrient = getNutrient(orderedNutrient)!;
        final RobotoffNutrientEntity? robotoffNutrientEntity =
            extractionResult.getNutrientEntity(nutrient, perSize);
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
        (!orderedNutrient.displayInEditForm) &&
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
        _perSize,
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

  List<Unit> getUnits(final Nutrient nutrient) {
    final List<Unit> units = <Unit>[
      Unit.G,
      Unit.MILLI_G,
      Unit.MICRO_G,
    ];

    if (units.contains(getUnit(nutrient))) {
      return units;
    } else {
      return <Unit>[];
    }
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

  void setNutrientUnit(final Nutrient nutrient, final Unit unit) {
    _setUnit(nutrient, unit, init: false);
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
            ? nutriments.getComputedKJ(_perSize)?.roundToDouble()
            : nutriments.getValue(nutrient, _perSize),
        unit,
      );
      if (value != null) {
        _values[nutrient] = value;
      }
    }
  }

  /// Returns true if the user edited something.
  bool isEdited() {
    if (_noNutritionData != _initialNoNutritionData) {
      return true;
    }
    if (_perSize != _initialPerSize) {
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
    product.noNutritionData = _noNutritionData;
    product.nutrimentDataPer = _perSize.offTag;
    product.nutriments = _getNutriments();
    product.servingSize = servingSize;
    return product;
  }
}
