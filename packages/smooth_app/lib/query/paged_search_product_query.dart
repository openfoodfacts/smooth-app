import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// Back-end paged queries around search.
abstract class PagedSearchProductQuery extends PagedProductQuery {
  PagedSearchProductQuery({required super.productType, super.world});

  Parameter getParameter();

  /// Returns the list of unwanted ingredients for the query.
  List<String> get unwantedIngredients;

  @override
  AbstractQueryConfiguration getQueryConfiguration() {
    return ProductSearchQueryConfiguration(
      fields: ProductQuery.fields,
      parametersList: <Parameter>[
        PageSize(size: pageSize),
        PageNumber(page: pageNumber),
        getParameter(),
        if (unwantedIngredients.isNotEmpty)
          IngredientsUnwantedParameter(unwantedIngredients),
      ],
      language: language,
      country: country,
      version: ProductQuery.productQueryVersion,
      activateKnowledgePanelsSimplified: true,
    );
  }
}
