import 'package:openfoodfacts/openfoodfacts.dart';

class NutritionValidator {
  bool validate(Nutrient nutrient, String? qty, Unit unit, String? servSize) {
    final double? quantity = _parseDouble(qty);
    final double? servingSize = _parseDouble(servSize);

    if ((quantity == null) || (servingSize == null)) {
      return true;
    }

    switch (nutrient) {
      case Nutrient.addedSugars:
        return _validateAddedSugars(quantity, unit, servingSize);
      case Nutrient.alcohol:
        return _validateAlcohol(quantity, unit, servingSize);
      case Nutrient.alphaLinolenicAcid:
        return _validateAlphaLinolenicAcid(quantity, unit, servingSize);
      case Nutrient.arachidicAcid:
        return _validateArachidicAcid(quantity, unit, servingSize);
      case Nutrient.arachidonicAcid:
        return _validateArachidonicAcid(quantity, unit, servingSize);
      case Nutrient.behenicAcid:
        return _validateBehenicAcid(quantity, unit, servingSize);
      case Nutrient.betaCarotene:
        return _validateBetaCarotene(quantity, unit, servingSize);
      case Nutrient.bicarbonate:
        return _validateBicarbonate(quantity, unit, servingSize);
      case Nutrient.biotin:
        return _validateBiotin(quantity, unit, servingSize);
      case Nutrient.butyricAcid:
        return _validateButyricAcid(quantity, unit, servingSize);
      case Nutrient.caffeine:
        return _validateCaffeine(quantity, unit, servingSize);
      case Nutrient.calcium:
        return _validateCalcium(quantity, unit, servingSize);
      case Nutrient.capricAcid:
        return _validateCapricAcid(quantity, unit, servingSize);
      case Nutrient.caproicAcid:
        return _validateCaproicAcid(quantity, unit, servingSize);
      case Nutrient.caprylicAcid:
        return _validateCaprylicAcid(quantity, unit, servingSize);
      case Nutrient.carbohydrates:
        return _validateCarbohydrates(quantity, unit, servingSize);
      case Nutrient.ceroticAcid:
        return _validateCeroticAcid(quantity, unit, servingSize);
      case Nutrient.chloride:
        return _validateChloride(quantity, unit, servingSize);
      case Nutrient.cholesterol:
        return _validateCholesterol(quantity, unit, servingSize);
      case Nutrient.chromium:
        return _validateChromium(quantity, unit, servingSize);
      case Nutrient.copper:
        return _validateCopper(quantity, unit, servingSize);
      case Nutrient.dihomoGammaLinolenicAcid:
        return _validateDihomoGammaLinolenicAcid(quantity, unit, servingSize);
      case Nutrient.docosahexaenoicAcid:
        return _validateDocosahexaenoicAcid(quantity, unit, servingSize);
      case Nutrient.elaidicAcid:
        return _validateElaidicAcid(quantity, unit, servingSize);
      case Nutrient.energyKCal:
        return _validateEnergyKCal(quantity, unit, servingSize);
      case Nutrient.energyKJ:
        return _validateEnergyKJ(quantity, unit, servingSize);
      case Nutrient.eicosapentaenoicAcid:
        return _validateEicosapentaenoicAcid(quantity, unit, servingSize);
      case Nutrient.erucicAcid:
        return _validateErucicAcid(quantity, unit, servingSize);
      case Nutrient.fat:
        return _validateFat(quantity, unit, servingSize);
      case Nutrient.fiber:
        return _validateFiber(quantity, unit, servingSize);
      case Nutrient.fluoride:
        return _validateFluoride(quantity, unit, servingSize);
      case Nutrient.gammaLinolenicAcid:
        return _validateGammaLinolenicAcid(quantity, unit, servingSize);
      case Nutrient.gondoicAcid:
        return _validateGondoicAcid(quantity, unit, servingSize);
      case Nutrient.iodine:
        return _validateIodine(quantity, unit, servingSize);
      case Nutrient.iron:
        return _validateIron(quantity, unit, servingSize);
      case Nutrient.lauricAcid:
        return _validateLauricAcid(quantity, unit, servingSize);
      case Nutrient.lignocericAcid:
        return _validateLignocericAcid(quantity, unit, servingSize);
      case Nutrient.linoleicAcid:
        return _validateLinoleicAcid(quantity, unit, servingSize);
      case Nutrient.magnesium:
        return _validateMagnesium(quantity, unit, servingSize);
      case Nutrient.manganese:
        return _validateManganese(quantity, unit, servingSize);
      case Nutrient.meadAcid:
        return _validateMeadAcid(quantity, unit, servingSize);
      case Nutrient.melissicAcid:
        return _validateMelissicAcid(quantity, unit, servingSize);
      case Nutrient.molybdenum:
        return _validateMolybdenum(quantity, unit, servingSize);
      case Nutrient.monounsaturatedFat:
        return _validateMonounsaturatedFat(quantity, unit, servingSize);
      case Nutrient.montanicAcid:
        return _validateMontanicAcid(quantity, unit, servingSize);
      case Nutrient.myristicAcid:
        return _validateMyristicAcid(quantity, unit, servingSize);
      case Nutrient.nervonicAcid:
        return _validateNervonicAcid(quantity, unit, servingSize);
      case Nutrient.oleicAcid:
        return _validateOleicAcid(quantity, unit, servingSize);
      case Nutrient.omega3:
        return _validateOmega3(quantity, unit, servingSize);
      case Nutrient.omega6:
        return _validateOmega6(quantity, unit, servingSize);
      case Nutrient.omega9:
        return _validateOmega9(quantity, unit, servingSize);
      case Nutrient.palmiticAcid:
        return _validatePalmiticAcid(quantity, unit, servingSize);
      case Nutrient.pantothenicAcid:
        return _validatePantothenicAcid(quantity, unit, servingSize);
      case Nutrient.phosphorus:
        return _validatePhosphorus(quantity, unit, servingSize);
      case Nutrient.polyunsaturatedFat:
        return _validatePolyunsaturatedFat(quantity, unit, servingSize);
      case Nutrient.potassium:
        return _validatePotassium(quantity, unit, servingSize);
      case Nutrient.proteins:
        return _validateProteins(quantity, unit, servingSize);
      case Nutrient.salt:
        return _validateSalt(quantity, unit, servingSize);
      case Nutrient.saturatedFat:
        return _validateSaturatedFat(quantity, unit, servingSize);
      case Nutrient.selenium:
        return _validateSelenium(quantity, unit, servingSize);
      case Nutrient.sodium:
        return _validateSodium(quantity, unit, servingSize);
      case Nutrient.stearicAcid:
        return _validateStearicAcid(quantity, unit, servingSize);
      case Nutrient.sugarAlcohol:
        return _validateSugarAlcohol(quantity, unit, servingSize);
      case Nutrient.sugars:
        return _validateSugars(quantity, unit, servingSize);
      case Nutrient.transFat:
        return _validateTransFat(quantity, unit, servingSize);
      case Nutrient.vitaminA:
        return _validateVitaminA(quantity, unit, servingSize);
      case Nutrient.vitaminB1:
        return _validateVitaminB1(quantity, unit, servingSize);
      case Nutrient.vitaminB12:
        return _validateVitaminB12(quantity, unit, servingSize);
      case Nutrient.vitaminB2:
        return _validateVitaminB2(quantity, unit, servingSize);
      case Nutrient.vitaminB6:
        return _validateVitaminB6(quantity, unit, servingSize);
      case Nutrient.vitaminB9:
        return _validateVitaminB9(quantity, unit, servingSize);
      case Nutrient.vitaminC:
        return _validateVitaminC(quantity, unit, servingSize);
      case Nutrient.vitaminD:
        return _validateVitaminD(quantity, unit, servingSize);
      case Nutrient.vitaminE:
        return _validateVitaminE(quantity, unit, servingSize);
      case Nutrient.vitaminK:
        return _validateVitaminK(quantity, unit, servingSize);
      case Nutrient.vitaminPP:
        return _validateVitaminPP(quantity, unit, servingSize);
      case Nutrient.zinc:
        return _validateZinc(quantity, unit, servingSize);
    }
  }

  bool _validateAddedSugars(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 50.0);

  bool _validateAlcohol(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.PERCENT, s), 100.0);

  bool _validateAlphaLinolenicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 10.0);

  bool _validateArachidicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 1.0);

  bool _validateArachidonicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 0.2);

  bool _validateBehenicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 1.0);

  bool _validateBetaCarotene(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 15.0);

  bool _validateBicarbonate(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 1000.0);

  bool _validateBiotin(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 300.0);

  bool _validateButyricAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 2.0);

  bool _validateCaffeine(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 0.4);

  bool _validateCalcium(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 1300.0);

  bool _validateCapricAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 2.0);

  bool _validateCaproicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 2.0);

  bool _validateCaprylicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 2.0);

  bool _validateCarbohydrates(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 100.0);

  bool _validateCeroticAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 1.0);

  bool _validateChloride(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 3600.0);

  bool _validateCholesterol(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 300.0);

  bool _validateChromium(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 35.0);

  bool _validateCopper(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 10.0);

  bool _validateDihomoGammaLinolenicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 0.1);

  bool _validateDocosahexaenoicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 1.0);

  bool _validateElaidicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 0.5);

  bool _validateEicosapentaenoicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 1.0);

  bool _validateEnergyKCal(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.KCAL, s), 900.0);

  bool _validateEnergyKJ(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.KJ, s), 3700.0);

  bool _validateErucicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 2.0);

  bool _validateFat(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 100.0);

  bool _validateFiber(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 30.0);

  bool _validateFluoride(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 10.0);

  bool _validateGammaLinolenicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 1.0);

  bool _validateGondoicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 1.0);

  bool _validateIodine(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 1100.0);

  bool _validateIron(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 45.0);

  bool _validateLauricAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 5.0);

  bool _validateLignocericAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 1.0);

  bool _validateLinoleicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 17.0);

  bool _validateMagnesium(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 420.0);

  bool _validateManganese(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 11.0);

  bool _validateMeadAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 0.1);

  bool _validateMelissicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 0.1);

  bool _validateMonounsaturatedFat(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 25.0);

  bool _validateMontanicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 0.1);

  bool _validateMolybdenum(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 2000.0);

  bool _validateMyristicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 5.0);

  bool _validateNervonicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 0.1);

  bool _validateOleicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 40.0);

  bool _validateOmega3(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 2000.0);

  bool _validateOmega6(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 17000.0);

  bool _validateOmega9(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 40000.0);

  bool _validatePalmiticAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 10.0);

  bool _validatePantothenicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 10.0);

  bool _validatePhosphorus(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 1250.0);

  bool _validatePolyunsaturatedFat(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 11.0);

  bool _validatePotassium(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 4700.0);

  bool _validateProteins(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 100.0);

  bool _validateSalt(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 6.0);

  bool _validateSaturatedFat(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 20.0);

  bool _validateSelenium(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 400.0);

  bool _validateSodium(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 2.4);

  bool _validateStearicAcid(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 5.0);

  bool _validateSugarAlcohol(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 50.0);

  bool _validateSugars(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 90.0);

  bool _validateTransFat(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.G, s), 2.0);

  bool _validateVitaminA(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 3000.0);

  bool _validateVitaminB1(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 50.0);

  bool _validateVitaminB12(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 2000.0);

  bool _validateVitaminB2(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 50.0);

  bool _validateVitaminB6(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 100.0);

  bool _validateVitaminB9(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 1000.0);

  bool _validateVitaminC(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 2000.0);

  bool _validateVitaminD(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 100.0);

  bool _validateVitaminE(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 1000.0);

  bool _validateVitaminK(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MICRO_G, s), 120.0);

  bool _validateVitaminPP(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 35.0);

  bool _validateZinc(double q, Unit u, double s) =>
      _validateMax(_normalize(q, u, Unit.MILLI_G, s), 40.0);

  double _normalize(
      double quantity, Unit inputUnit, Unit typicalUnit, double servingWeight) {
    final double factor = _unitConversionFactor(inputUnit, typicalUnit);
    final double normalized = (quantity * factor) * (100.0 / servingWeight);
    return normalized;
  }

  bool _validateMax(double normalizedValue, double maxAllowed) {
    return normalizedValue <= maxAllowed;
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

  double? _parseDouble(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }

    input = input.trim().toLowerCase();

    final RegExp regex = RegExp(r'^([0-9]+\.?[0-9]*)\s*([a-zA-Z%]+)?$');
    final RegExpMatch? match = regex.firstMatch(input);

    if (match == null) {
      throw FormatException('Invalid input format: $input');
    }

    final double value = double.parse(match.group(1)!);

    // Default to grams if unit not specified
    final String unitStr = match.group(2) ?? 'g';

    // Convert unit string to Unit enum
    final Unit unit = UnitHelper.stringToUnit(unitStr) ?? Unit.G;

    // Use _unitConversionFactor to convert from source unit to grams
    return value * _unitConversionFactor(unit, Unit.G);
  }
}
