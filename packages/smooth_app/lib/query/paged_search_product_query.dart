import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// Back-end paged queries around search.
abstract class PagedSearchProductQuery extends PagedProductQuery {
  PagedSearchProductQuery({required super.productType, super.world});

  Parameter getParameter();

  IngredientsUnwantedParameter getUnwantedIngredientsParameter();

  @override
  AbstractQueryConfiguration getQueryConfiguration() {
    // Knowledge panels are most of the response and no result tile shows
    // them: the product page downloads them when opened.
    final List<ProductField> fields = List<ProductField>.from(
      ProductQuery.fields,
      growable: true,
    );
    fields.remove(ProductField.KNOWLEDGE_PANELS);
    return ProductSearchQueryConfiguration(
      fields: fields,
      parametersList: <Parameter>[
        PageSize(size: pageSize),
        PageNumber(page: pageNumber),
        getParameter(),
        getUnwantedIngredientsParameter(),
      ],
      language: language,
      country: country,
      version: ProductQuery.productQueryVersion,
    );
  }
}
