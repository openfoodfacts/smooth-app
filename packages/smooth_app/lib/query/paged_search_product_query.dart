import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/AbstractQueryConfiguration.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// Back-end paged queries around search.
abstract class PagedSearchProductQuery extends PagedProductQuery {
  PagedSearchProductQuery({super.world});

  Parameter getParameter();

  @override
  AbstractQueryConfiguration getQueryConfiguration() =>
      ProductSearchQueryConfiguration(
        fields: ProductQuery.fields,
        parametersList: <Parameter>[
          PageSize(size: pageSize),
          PageNumber(page: pageNumber),
          getParameter(),
        ],
        language: language,
        country: country,
      );
}
