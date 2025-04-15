import 'package:openfoodfacts/openfoodfacts.dart';

extension OpenFoodFactsCountryIso2Extension on OpenFoodFactsCountry {
  String get iso2Code =>
      this == OpenFoodFactsCountry.UNITED_KINGDOM ? 'GB' : offTag.toUpperCase();
}
