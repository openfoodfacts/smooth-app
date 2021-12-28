import 'dart:async';

import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:openfoodfacts/utils/QueryType.dart';

class KnowledgePanelsQuery {
  KnowledgePanelsQuery({
    required this.barcode,
    required this.country,
    required this.language,
  });

  final String barcode;
  final OpenFoodFactsCountry? country;
  final OpenFoodFactsLanguage? language;

  Future<KnowledgePanels> getKnowledgePanels() async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language: language,
      country: country,
    );
    return OpenFoodAPIClient.getKnowledgePanels(configuration, QueryType.PROD);
  }
}
