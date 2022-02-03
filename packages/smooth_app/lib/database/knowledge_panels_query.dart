import 'dart:async';

import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
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
      fields: <ProductField>[ProductField.KNOWLEDGE_PANELS],
      version: ProductQueryVersion.v2,
    );

    try {
      final ProductResult productResult = await OpenFoodAPIClient.getProduct(
        configuration,
      );
      return productResult.product!.knowledgePanels!;
    } catch (exception) {
      // TODO(jasmeetsingh): Capture the exception in Sentry and don't log it here.
      return KnowledgePanels.empty();
    }
  }
}
