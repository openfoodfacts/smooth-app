import 'package:openfoodfacts/openfoodfacts.dart';

class NutritionValidator {
  final Map<Nutrient, double> nutrientMaxContentPer100g = <Nutrient, double>{
    Nutrient.salt: 100.0,
    Nutrient.sodium: 40.0,
    Nutrient.fiber: 100.0,
    Nutrient.sugars: 100.0,
    Nutrient.addedSugars: 100.0,
    Nutrient.fat: 100.0,
    Nutrient.saturatedFat: 100.0,
    Nutrient.proteins: 100.0,
    Nutrient.energyKCal: 900.0,
    Nutrient.energyKJ: 3700.0,
    Nutrient.carbohydrates: 100.0,
    Nutrient.caffeine: 80.0,
    Nutrient.calcium: 5000.0,
    Nutrient.iron: 100.0,
    Nutrient.vitaminC: 6000.0,
    Nutrient.magnesium: 2000.0,
    Nutrient.phosphorus: 5000.0,
    Nutrient.potassium: 5000.0,
    Nutrient.zinc: 1000.0,
    Nutrient.copper: 1000.0,
    Nutrient.selenium: 1000.0,
    Nutrient.vitaminA: 3000.0,
    Nutrient.vitaminE: 1000.0,
    Nutrient.vitaminD: 100.0,
    Nutrient.vitaminB1: 5.0,
    Nutrient.vitaminB2: 5.0,
    Nutrient.vitaminPP: 50.0,
    Nutrient.vitaminB6: 5.0,
    Nutrient.vitaminB12: 500.0,
    Nutrient.vitaminB9: 1000.0,
    Nutrient.vitaminK: 1000.0,
    Nutrient.cholesterol: 500.0,
    Nutrient.butyricAcid: 5.0,
    Nutrient.caproicAcid: 5.0,
    Nutrient.caprylicAcid: 5.0,
    Nutrient.capricAcid: 5.0,
    Nutrient.lauricAcid: 5.0,
    Nutrient.myristicAcid: 10.0,
    Nutrient.palmiticAcid: 20.0,
    Nutrient.stearicAcid: 20.0,
    Nutrient.oleicAcid: 80.0,
    Nutrient.linoleicAcid: 70.0,
    Nutrient.docosahexaenoicAcid: 5.0,
    Nutrient.eicosapentaenoicAcid: 5.0,
    Nutrient.erucicAcid: 5.0,
    Nutrient.monounsaturatedFat: 80.0,
    Nutrient.polyunsaturatedFat: 70.0,
    Nutrient.alcohol: 100.0,
    Nutrient.pantothenicAcid: 20.0,
    Nutrient.biotin: 500.0,
    Nutrient.chloride: 1000.0,
    Nutrient.chromium: 500.0,
    Nutrient.fluoride: 10.0,
    Nutrient.iodine: 1000.0,
    Nutrient.manganese: 20.0,
    Nutrient.molybdenum: 1000.0,
    Nutrient.omega3: 30.0,
    Nutrient.omega6: 70.0,
    Nutrient.omega9: 80.0,
    Nutrient.betaCarotene: 50.0,
    Nutrient.bicarbonate: 500.0,
    Nutrient.sugarAlcohol: 100.0,
    Nutrient.alphaLinolenicAcid: 10.0,
    Nutrient.arachidicAcid: 5.0,
    Nutrient.arachidonicAcid: 5.0,
    Nutrient.behenicAcid: 5.0,
    Nutrient.ceroticAcid: 5.0,
    Nutrient.dihomoGammaLinolenicAcid: 5.0,
    Nutrient.elaidicAcid: 5.0,
    Nutrient.gammaLinolenicAcid: 5.0,
    Nutrient.gondoicAcid: 5.0,
    Nutrient.lignocericAcid: 5.0,
    Nutrient.meadAcid: 5.0,
    Nutrient.melissicAcid: 5.0,
    Nutrient.montanicAcid: 5.0,
    Nutrient.nervonicAcid: 5.0,
    Nutrient.transFat: 100.0,
  };

  bool validate(Nutrient nutrient, String? qty, Unit unit, String? servSize) {
    final double? quantity = _parseValueWithUnit(qty);
    final double? servingSize = _parseValueWithUnit(servSize);

    if ((quantity == null) || (servingSize == null)) {
      return true;
    }

    final double limit = nutrientMaxContentPer100g[nutrient] ?? 100;
    return _normalize(quantity, unit, nutrient.typicalUnit, servingSize) <=
        limit;
  }

  double _normalize(
      double quantity, Unit inputUnit, Unit typicalUnit, double servingSize) {
    final double factor = _unitConversionFactor(inputUnit, typicalUnit);
    final double normalized = (quantity * factor) * (100.0 / servingSize);
    return normalized;
  }

  double _unitConversionFactor(Unit from, Unit to) {
    if (from == to) {
      return 1.0;
    }
    // Mass conversions
    if (from == Unit.G && to == Unit.MILLI_G) {
      return 1000.0;
    }
    if (from == Unit.MILLI_G && to == Unit.G) {
      return 0.001;
    }
    if (from == Unit.MICRO_G && to == Unit.G) {
      return 0.000001;
    }
    if (from == Unit.G && to == Unit.MICRO_G) {
      return 1000000.0;
    }
    if (from == Unit.MILLI_G && to == Unit.MICRO_G) {
      return 1000.0;
    }
    if (from == Unit.MICRO_G && to == Unit.MILLI_G) {
      return 0.001;
    }
    // Energy conversions
    if (from == Unit.KCAL && to == Unit.KJ) {
      return 4.184;
    }
    if (from == Unit.KJ && to == Unit.KCAL) {
      return 0.239006;
    }
    // Volume conversions
    if (from == Unit.L && to == Unit.MILLI_L) {
      return 1000.0;
    }
    if (from == Unit.MILLI_L && to == Unit.L) {
      return 0.001;
    }
    // Percentage is dimensionless - no conversion needed
    if (from == Unit.PERCENT || to == Unit.PERCENT) {
      return 1.0;
    }

    return 1.0;
  }

  double? _parseValueWithUnit(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }

    try {
      input = input.trim().toLowerCase();
      final RegExp regex = RegExp(r'^([0-9]+\.?[0-9]*)\s*([a-zA-Z%]+)?$');
      final RegExpMatch? match = regex.firstMatch(input);
      if (match == null) {
        return null; // Invalid format
      }
      final double value = double.parse(match.group(1)!);
      // Default to grams if unit not specified
      final String unitStr = match.group(2) ?? 'g';
      // Convert unit string to Unit enum
      final Unit unit = UnitHelper.stringToUnit(unitStr) ?? Unit.G;
      // Use _unitConversionFactor to convert from source unit to grams
      return value * _unitConversionFactor(unit, Unit.G);
    } catch (e) {
      return null; // Handle any parsing errors
    }
  }
}
