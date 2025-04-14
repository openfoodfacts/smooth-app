import 'package:openfoodfacts/openfoodfacts.dart';

extension OpenFoodFactsCountryIso2Extension on OpenFoodFactsCountry {
  String get iso2Code => offTag.toUpperCase() == 'UK' ? 'GB' : offTag.toUpperCase();
}

