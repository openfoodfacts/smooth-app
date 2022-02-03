import 'dart:convert';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/abstract_onboarding_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/database/tmp.dart';

/// Helper around a product we download, store and reuse at onboarding.
class OnboardingDataProduct extends AbstractOnboardingData<Product> {
  OnboardingDataProduct(final LocalDatabase _localDatabase)
      : super(_localDatabase);

  @override
  Product getDataFromNonNullString(final String jsonString) {
    final Map<String, dynamic> productData =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return Product.fromJson(productData['product'] as Map<String, dynamic>);
  }

  @override
  Future<String> downloadDataString() async =>
      OpenFoodAPIClientTmp.getProductString(
        ProductQueryConfiguration(
          AbstractOnboardingData.barcode,
          fields: ProductQuery.fields,
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
        ),
      );

  /// Was computed from [downloadDataString] in en_US
  ///
  /// Something like https://world.openfoodfacts.org/api/v0/product/093270067481501.json?lc=en&cc=US&fields=product_name%2Cbrands%2Ccode%2Cnutrition_grade_fr%2Cimage_small_url%2Cimage_front_small_url%2Cimage_front_url%2Cimage_ingredients_url%2Cimage_nutrition_url%2Cimage_packaging_url%2Cselected_images%2Cquantity%2Cserving_size%2Cproduct_quantity%2Cnutriments%2Cnutrient_levels%2Cnutriment_energy_unit%2Cadditives_tags%2Cingredients_analysis_tags%2Clabels_tags%2Clabels_tags_fr%2Cenvironment_impact_level_tags%2Ccategories_tags_fr%2Clang%2Cattribute_groups%2Cstates_tags%2Cecoscore_data%2Cecoscore_grade%2Cecoscore_score%2Cenvironment_impact_level_tags
  @override
  String getAssetPath() => 'assets/onboarding/sample_product_data.json';
}
