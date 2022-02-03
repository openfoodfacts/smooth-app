import 'dart:convert';

import 'package:openfoodfacts/model/KnowledgePanels.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/abstract_onboarding_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/database/tmp.dart';

/// Helper around knowledge panels we download, store and reuse at onboarding.
class OnboardingDataKnowledgePanels
    extends AbstractOnboardingData<KnowledgePanels> {
  OnboardingDataKnowledgePanels(final LocalDatabase _localDatabase)
      : super(_localDatabase);

  @override
  KnowledgePanels getDataFromNonNullString(final String jsonString) {
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final Map<String, dynamic> product =
        json['product'] as Map<String, dynamic>;
    final Map<String, dynamic> knowledgePanelsJson =
        product[OpenFoodAPIClientTmp.KNOWLEDGE_PANELS_FIELD]
            as Map<String, dynamic>;
    return KnowledgePanels.fromJson(knowledgePanelsJson);
  }

  @override
  Future<String> downloadDataString() async =>
      OpenFoodAPIClientTmp.getKnowledgePanelsString(
        ProductQueryConfiguration(
          AbstractOnboardingData.barcode,
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
        ),
      );

  /// Was computed from [downloadDataString] in en_US
  ///
  /// Something like https://world.openfoodfacts.org/api/v2/product/093270067481501/?fields=knowledge_panels&lc=en&cc=US
  @override
  String getAssetPath() => 'assets/onboarding/sample_knowledge_panels.json';
}
