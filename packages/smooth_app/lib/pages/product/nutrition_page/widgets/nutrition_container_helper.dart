import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_nutrition_extension.dart';
import 'package:smooth_app/query/product_query.dart';

/// Nutrition data, for nutrient order and conversions.
class NutritionContainerHelper extends ChangeNotifier {
  NutritionContainerHelper({
    required OrderedNutrients orderedNutrients,
    required Product product,
  }) {
    bool hasValues(
      PerSize perSize,
      List<String> sources, {
      bool withOldValues = false,
    }) => product
        .getNutritionValues(
          perSize,
          sources: sources,
          withOldValues: withOldValues,
        )
        .isNotEmpty;
    bool hasSetValues(String source) =>
        hasValues(PerSize.oneHundredGrams, <String>[source]) ||
        hasValues(PerSize.serving, <String>[source]);
    final bool hasPackagingValues = hasSetValues(
      NutritionSetKey.sourcePackaging,
    );
    // The end-user's own per size wins over the manufacturer's.
    final List<String> perSizeSources = hasPackagingValues
        ? <String>[NutritionSetKey.sourcePackaging]
        : ProductNutritionExtension.editorSources;
    final bool withOldValues =
        !hasValues(
          PerSize.oneHundredGrams,
          ProductNutritionExtension.editorSources,
        ) &&
        !hasValues(PerSize.serving, ProductNutritionExtension.editorSources);
    _initialPerSize = _perSize =
        !hasValues(
              PerSize.oneHundredGrams,
              perSizeSources,
              withOldValues: withOldValues,
            ) &&
            hasValues(
              PerSize.serving,
              perSizeSources,
              withOldValues: withOldValues,
            )
        ? PerSize.serving
        : PerSize.oneHundredGrams;
    _loadNutrients(orderedNutrients.nutrients);
    _loadValues(product);
    setServingText(product.servingSize);
    _initialServingSize = servingSize;
    _initialNoNutritionData = _noNutritionData = product.hasNoNutritionData;
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

  // TODO(UrbanFercec): all the units, not only weights.
  static const Map<Unit, Unit> _nextWeightUnits = <Unit, Unit>{
    Unit.G: Unit.MILLI_G,
    Unit.MILLI_G: Unit.MICRO_G,
    Unit.MICRO_G: Unit.G,
  };

  /// All the nutrients (country-related) that do match [Nutrient]s.
  final List<OrderedNutrient> _nutrients = <OrderedNutrient>[];

  List<OrderedNutrient> get allNutrients => _nutrients;

  /// Nutrient values.
  final Map<Nutrient, NutritionValue> _values = <Nutrient, NutritionValue>{};

  /// Texts typed by the end-user, with a dot as decimal separator, and
  /// different from the loaded values.
  ///
  /// An empty text means that the end-user cleared the nutrient.
  final Map<Nutrient, String> _edited = <Nutrient, String>{};

  /// Nutrient units.
  final Map<Nutrient, Unit> _units = <Nutrient, Unit>{};

  /// Initial nutrient units.
  final Map<Nutrient, Unit> _initialUnits = <Nutrient, Unit>{};

  /// Nutrients whose loaded value comes from the manufacturer.
  final Set<Nutrient> _fromManufacturer = <Nutrient>{};

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

  late PerSize _perSize;
  late PerSize _initialPerSize;
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
  num? getValue(Nutrient nutrient) => _values[nutrient]?.value;

  /// Returns true if the loaded value of [nutrient] comes from the manufacturer.
  bool isFromManufacturer(Nutrient nutrient) =>
      _fromManufacturer.contains(nutrient);

  /// Stores the end-user input when it differs from the loaded value.
  ///
  /// Empty text and the editor's "-" (missing value) clear the value; any
  /// other text that can't be parsed is ignored.
  void setNutrientValueText(
    Nutrient nutrient,
    String? text,
    NumberFormat numberFormat,
  ) {
    num? value;
    final String trimmed = text?.trim() ?? '';
    if (trimmed.isNotEmpty && trimmed != '-') {
      value = numberFormat.tryParse(trimmed);
      if (value == null) {
        _edited.remove(nutrient);
        return;
      }
    }
    final num? loaded = getValue(nutrient);
    final bool unchanged = value == null || loaded == null
        ? value == loaded
        : numberFormat.format(value) == numberFormat.format(loaded);
    if (unchanged) {
      _edited.remove(nutrient);
    } else {
      _edited[nutrient] = value == null
          ? ''
          : trimmed.replaceAll(numberFormat.symbols.DECIMAL_SEP, '.');
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
  Unit getUnit(Nutrient nutrient) => _units[nutrient]!;

  /// Stores the nutrient [Unit].
  void setNutrientUnit(Nutrient nutrient, Unit unit) => _units[nutrient] = unit;

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

  /// Loads the values and units of the as sold nutrition.
  ///
  /// Needs nutrients to be loaded first.
  void _loadValues(Product product) {
    final Map<Nutrient, NutritionValue> nutritionValues = product
        .getNutritionValues(
          _perSize,
          sources: ProductNutritionExtension.editorSources,
        );
    Map<Nutrient, NutritionValue> getSetValues(String source) =>
        product.getNutritionValues(
          _perSize,
          sources: <String>[source],
          withOldValues: false,
        );
    final Map<Nutrient, NutritionValue> packagingValues = getSetValues(
      NutritionSetKey.sourcePackaging,
    );
    final Map<Nutrient, NutritionValue> manufacturerValues = getSetValues(
      NutritionSetKey.sourceManufacturer,
    );
    for (final Map<Nutrient, NutritionValue> values
        in <Map<Nutrient, NutritionValue>>[
          packagingValues,
          manufacturerValues,
          nutritionValues,
        ]) {
      final num? kCal = values[Nutrient.energyKCal]?.value;
      if (values[Nutrient.energyKJ] == null && kCal != null) {
        values[Nutrient.energyKJ] = NutritionValue(
          value: NutrimentsHelper.fromKCalToKJ(kCal.toDouble()).round(),
          unit: Unit.KJ,
        );
      }
    }
    final NutritionValue? setKJ =
        packagingValues[Nutrient.energyKJ] ??
        manufacturerValues[Nutrient.energyKJ];
    if (setKJ != null) {
      nutritionValues[Nutrient.energyKJ] = setKJ;
    }
    for (final OrderedNutrient orderedNutrient in _nutrients) {
      final Nutrient nutrient = getNutrient(orderedNutrient)!;
      final NutritionValue? nutritionValue = nutritionValues[nutrient];
      final Unit unit = nutritionValue?.unit ?? nutrient.typicalUnit;
      _units[nutrient] = unit;
      _initialUnits[nutrient] = unit;
      if (nutritionValue != null) {
        _values[nutrient] = nutritionValue;
        if (packagingValues[nutrient] == null &&
            manufacturerValues[nutrient] != null) {
          _fromManufacturer.add(nutrient);
        }
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

  /// Plain decimal, no exponent nor group separator.
  static NumberFormat getNumberFormat(String locale) =>
      NumberFormat('####0.########', locale);

  static final NumberFormat _writeFormat = getNumberFormat('en');

  /// Returns the stored value string, or the formatted value when it is
  /// missing or has an exponent.
  static String? _getValueString(NutritionValue? nutritionValue) {
    final String? valueString = nutritionValue?.valueString;
    if (valueString != null &&
        valueString.isNotEmpty &&
        !valueString.contains('e')) {
      return valueString;
    }
    final num? value = nutritionValue?.value;
    return value == null ? null : _writeFormat.format(value);
  }

  /// Returns the packaging nutrition sets with only the changed nutrients.
  ///
  /// When the end-user changes the per size, all the values move to the new
  /// set.
  List<NutritionSet> _getChangedSets() {
    final bool perSizeChanged = _perSize != _initialPerSize;
    final Map<Nutrient, NutritionValue> nutritionValues =
        <Nutrient, NutritionValue>{};
    final Map<Nutrient, NutritionValue> removedValues =
        <Nutrient, NutritionValue>{};
    for (final OrderedNutrient orderedNutrient in _nutrients) {
      final Nutrient nutrient = getNutrient(orderedNutrient)!;
      final NutritionValue? loaded = _values[nutrient];
      final bool fromManufacturer = _fromManufacturer.contains(nutrient);
      final String? edited = _edited[nutrient];
      final Unit unit = _units[nutrient]!;
      if (perSizeChanged && loaded != null && !fromManufacturer) {
        removedValues[nutrient] = NutritionValue(
          unit: _initialUnits[nutrient],
          valueString: '',
        );
      }
      if (!perSizeChanged &&
          edited == null &&
          unit == _initialUnits[nutrient]) {
        continue;
      }
      // A manufacturer value is for its own per size only.
      final NutritionValue? kept = perSizeChanged && fromManufacturer
          ? null
          : loaded;
      final String? valueString = edited ?? _getValueString(kept);
      if (valueString == null ||
          (valueString.isEmpty &&
              (kept == null || fromManufacturer || perSizeChanged))) {
        continue;
      }
      nutritionValues[nutrient] = NutritionValue(
        unit: unit,
        valueString: valueString,
        modifier: edited == null ? kept?.modifier : null,
      );
    }
    NutritionSet getPackagingSet(
      PerSize perSize,
      Map<Nutrient, NutritionValue> packagingValues,
    ) => NutritionSet(
      key: NutritionSetKey(
        source: NutritionSetKey.sourcePackaging,
        preparation: NutritionSetKey.preparationAsSold,
        perSize: perSize,
      ),
      nutritionValues: packagingValues,
    );
    return <NutritionSet>[
      if (removedValues.isNotEmpty)
        getPackagingSet(_initialPerSize, removedValues),
      if (nutritionValues.isNotEmpty)
        getPackagingSet(_perSize, nutritionValues),
    ];
  }

  /// Returns the minimal products to save, with only the changed data.
  ///
  /// The nutrition values are saved in V3, which doesn't save the "no nutrition
  /// data" flag, hence a separate product.
  List<Product> getChangedProducts(String barcode) {
    final List<Product> result = <Product>[];
    final Product nutritionProduct = Product(barcode: barcode);
    final List<NutritionSet> changedSets = _getChangedSets();
    if (changedSets.isNotEmpty) {
      NutritionHelper().setInputSets(nutritionProduct, changedSets);
    }
    if (servingSize != _initialServingSize) {
      nutritionProduct.servingSize = servingSize;
    }
    if (nutritionProduct.nutrition != null ||
        nutritionProduct.servingSize != null) {
      result.add(nutritionProduct);
    }
    if (_noNutritionData != _initialNoNutritionData) {
      result.add(Product(barcode: barcode)..noNutritionData = _noNutritionData);
    }
    return result;
  }
}
