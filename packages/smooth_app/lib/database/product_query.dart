import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:smooth_app/data_models/product_list.dart';

abstract class ProductQuery {
  static const User SMOOTH_USER = User(
    userId: 'project-smoothie',
    password: 'smoothie',
    comment: 'Test user for project smoothie',
  );

  static const List<ProductField> fields = <ProductField>[
    ProductField.NAME,
    ProductField.BRANDS,
    ProductField.BARCODE,
    ProductField.NUTRISCORE,
    ProductField.FRONT_IMAGE,
    ProductField.SELECTED_IMAGE,
    ProductField.QUANTITY,
    ProductField.SERVING_SIZE,
    ProductField.PACKAGING_QUANTITY,
    ProductField.NUTRIMENTS,
    ProductField.NUTRIENT_LEVELS,
    ProductField.NUTRIMENT_ENERGY_UNIT,
    ProductField.ADDITIVES,
    ProductField.INGREDIENTS_ANALYSIS_TAGS,
    ProductField.LABELS_TAGS,
    ProductField.ENVIRONMENT_IMPACT_LEVELS,
    ProductField.CATEGORIES_TAGS,
    ProductField.LANGUAGE,
    ProductField.ATTRIBUTE_GROUPS,
  ];

  Future<SearchResult> getSearchResult();

  ProductList getProductList();
}
