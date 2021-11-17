import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:smooth_app/database/product_query.dart';

class KnowledgePanelsQuery {
  KnowledgePanelsQuery({
    required this.barcode,
  });

  final String barcode;

  Future<KnowledgePanels> getKnowledgePanels(BuildContext context) async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language:
          LanguageHelper.fromJson(ProductQuery.getCurrentLanguageCode(context)),
      cc: ProductQuery.getCurrentCountryCode(),
    );
    return OpenFoodAPIClient.getKnowledgePanels(configuration, QueryType.TEST);
  }
}
