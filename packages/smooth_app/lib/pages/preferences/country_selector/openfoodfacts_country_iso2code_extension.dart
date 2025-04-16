import 'package:openfoodfacts/openfoodfacts.dart';

extension OpenFoodFactsCountryIso2Extension on OpenFoodFactsCountry {
  // Uses iso2Code to display the UI and emoji.
  String get iso2Code =>
      this == OpenFoodFactsCountry.UNITED_KINGDOM ? 'GB' : offTag.toUpperCase();
}
