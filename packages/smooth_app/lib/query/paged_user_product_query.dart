import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// User-related Product Search Type.
enum UserSearchType {
  /// Where the user created the product.
  CONTRIBUTOR(TagFilterType.CREATOR),

  /// Where the user edited the product.
  INFORMER(TagFilterType.INFORMERS),

  /// Where the user photographed the product.
  PHOTOGRAPHER(TagFilterType.PHOTOGRAPHERS),

  /// Where the user edited a product that still needs to be completed.
  TO_BE_COMPLETED(TagFilterType.INFORMERS, toBeCompleted: true);

  const UserSearchType(this.type, {this.toBeCompleted = false});

  final TagFilterType type;
  final bool toBeCompleted;

  ProductSearchQueryConfiguration getConfiguration(
    final String userId,
    final int pageSize,
    final int pageNumber,
    final OpenFoodFactsLanguage language,
    final List<ProductField> fields,
  ) => ProductSearchQueryConfiguration(
    parametersList: <Parameter>[
      TagFilter.fromType(tagFilterType: type, tagName: userId),
      PageSize(size: pageSize),
      PageNumber(page: pageNumber),
      if (toBeCompleted)
        const StatesTagsParameter(
          map: <ProductState, bool>{ProductState.COMPLETED: false},
        ),
    ],
    language: language,
    fields: fields,
    version: ProductQuery.productQueryVersion,
  );
}

/// Back-end paged queries around User.
class PagedUserProductQuery extends PagedProductQuery {
  PagedUserProductQuery({
    required this.userId,
    required this.type,
    required super.productType,
  });

  final String userId;
  final UserSearchType type;

  @override
  AbstractQueryConfiguration getQueryConfiguration() => type.getConfiguration(
    userId,
    pageSize,
    pageNumber,
    language,
    ProductQuery.fields,
  );

  @override
  ProductList getProductList() {
    switch (type) {
      case UserSearchType.CONTRIBUTOR:
        return ProductList.contributor(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: language,
          productType: productType,
        );
      case UserSearchType.INFORMER:
        return ProductList.informer(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: language,
          productType: productType,
        );
      case UserSearchType.PHOTOGRAPHER:
        return ProductList.photographer(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: language,
          productType: productType,
        );
      case UserSearchType.TO_BE_COMPLETED:
        return ProductList.toBeCompleted(
          userId,
          pageSize: pageSize,
          pageNumber: pageNumber,
          language: language,
          productType: productType,
        );
    }
  }

  @override
  String toString() =>
      'PagedUserProductQuery('
      '$type'
      ', "$userId"'
      ', $pageSize'
      ', $pageNumber'
      ', $language'
      ', $productType'
      ')';
}
