import 'dart:async';

import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:smooth_app/database/product_query.dart';

class KnowledgePanelsQuery {
  KnowledgePanelsQuery({
    required this.barcode,
  });

  final String barcode;

  Future<KnowledgePanels> getKnowledgePanels() async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language: ProductQuery.getLanguage(),
      country: ProductQuery.getCountry(),
    );
    return OpenFoodAPIClient.getKnowledgePanels(configuration, QueryType.PROD);
  }
}
