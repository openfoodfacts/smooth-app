import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// Back-end paged query for all "to-be-completed" products.
class PagedToBeCompletedProductQuery extends PagedProductQuery {
  PagedToBeCompletedProductQuery({required super.productType, super.world});

  @override
  AbstractQueryConfiguration getQueryConfiguration() =>
      ProductSearchQueryConfiguration(
        language: language,
        country: country,
        fields: ProductQuery.fields,
        parametersList: <Parameter>[
          PageSize(size: pageSize),
          PageNumber(page: pageNumber),
          const StatesTagsParameter(
            map: <ProductState, bool>{ProductState.CATEGORIES_COMPLETED: false},
          ),
          const SortBy(option: SortOption.EDIT),
        ],
        version: ProductQuery.productQueryVersion,
      );

  @override
  ProductList getProductList() => ProductList.allToBeCompleted(
    pageSize: pageSize,
    pageNumber: pageNumber,
    language: language,
    country: country,
    productType: productType,
  );

  @override
  String toString() =>
      'PagedToBeCompletedProductQuery('
      '$pageSize'
      ', $pageNumber'
      ', $language'
      ', $country'
      ', $productType'
      ')';

  @override
  PagedProductQuery? getWorldQuery() => world
      ? null
      : PagedToBeCompletedProductQuery(productType: productType, world: true);

  @override
  bool hasDifferentCountryWorldData() => true;
}
