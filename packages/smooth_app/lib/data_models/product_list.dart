import 'package:openfoodfacts/openfoodfacts.dart';

enum ProductListType {
  /// API search by [SearchTerms] keywords
  HTTP_SEARCH_KEYWORDS('http/search/keywords'),

  /// API search for [CategoryProductQuery] category
  HTTP_SEARCH_CATEGORY('http/search/category'),

  /// Current scan session; can be easily cleared by the end-user
  SCAN_SESSION('scan_session'),

  /// Whole scan history; items may be removed by the end-user
  SCAN_HISTORY('scan_history'),

  /// History of products seen by the end-user
  HISTORY('history'),

  /// End-user product list
  USER('user'),

  /// End-user as a contributor
  HTTP_USER_CONTRIBUTOR('http/user/contributor'),

  /// End-user as an informer
  HTTP_USER_INFORMER('http/user/informer'),

  /// End-user as a photographer
  HTTP_USER_PHOTOGRAPHER('http/user/photographer'),

  /// End-user for products to be completed
  HTTP_USER_TO_BE_COMPLETED('http/user/to_be_completed'),

  /// For products to be completed, all of them.
  HTTP_ALL_TO_BE_COMPLETED('http/all/to_be_completed');

  const ProductListType(this.key);

  final String key;
}

class ProductList {
  ProductList._({
    required this.listType,
    this.parameters = '',
    this.pageSize = 0,
    this.pageNumber = 0,
    this.language,
    this.country,
    this.productType,
  });

  ProductList.keywordSearch(
    final String keywords, {
    required int pageSize,
    required int pageNumber,
    required OpenFoodFactsLanguage language,
    required OpenFoodFactsCountry? country,
    required ProductType productType,
  }) : this._(
         listType: ProductListType.HTTP_SEARCH_KEYWORDS,
         parameters: keywords,
         pageSize: pageSize,
         pageNumber: pageNumber,
         language: language,
         country: country,
         productType: productType,
       );

  ProductList.categorySearch(
    final String category, {
    required int pageSize,
    required int pageNumber,
    required OpenFoodFactsLanguage language,
    required OpenFoodFactsCountry? country,
    required ProductType productType,
  }) : this._(
         listType: ProductListType.HTTP_SEARCH_CATEGORY,
         parameters: category,
         pageSize: pageSize,
         pageNumber: pageNumber,
         language: language,
         country: country,
         productType: productType,
       );

  ProductList.contributor(
    final String userId, {
    required int pageSize,
    required int pageNumber,
    required OpenFoodFactsLanguage language,
    required ProductType productType,
  }) : this._(
         listType: ProductListType.HTTP_USER_CONTRIBUTOR,
         parameters: userId,
         pageSize: pageSize,
         pageNumber: pageNumber,
         language: language,
         productType: productType,
       );

  ProductList.informer(
    final String userId, {
    required int pageSize,
    required int pageNumber,
    required OpenFoodFactsLanguage language,
    required ProductType productType,
  }) : this._(
         listType: ProductListType.HTTP_USER_INFORMER,
         parameters: userId,
         pageSize: pageSize,
         pageNumber: pageNumber,
         language: language,
         productType: productType,
       );

  ProductList.photographer(
    final String userId, {
    required int pageSize,
    required int pageNumber,
    required OpenFoodFactsLanguage language,
    required ProductType productType,
  }) : this._(
         listType: ProductListType.HTTP_USER_PHOTOGRAPHER,
         parameters: userId,
         pageSize: pageSize,
         pageNumber: pageNumber,
         language: language,
         productType: productType,
       );

  ProductList.toBeCompleted(
    final String userId, {
    required int pageSize,
    required int pageNumber,
    required OpenFoodFactsLanguage language,
    required ProductType productType,
  }) : this._(
         listType: ProductListType.HTTP_USER_TO_BE_COMPLETED,
         parameters: userId,
         pageSize: pageSize,
         pageNumber: pageNumber,
         language: language,
         productType: productType,
       );

  ProductList.allToBeCompleted({
    required int pageSize,
    required int pageNumber,
    required OpenFoodFactsLanguage language,
    required OpenFoodFactsCountry? country,
    required ProductType productType,
  }) : this._(
         listType: ProductListType.HTTP_ALL_TO_BE_COMPLETED,
         pageSize: pageSize,
         pageNumber: pageNumber,
         language: language,
         country: country,
         productType: productType,
       );

  ProductList.history() : this._(listType: ProductListType.HISTORY);

  ProductList.scanSession() : this._(listType: ProductListType.SCAN_SESSION);

  ProductList.scanHistory() : this._(listType: ProductListType.SCAN_HISTORY);

  ProductList.user(final String name)
    : this._(listType: ProductListType.USER, parameters: name);

  final ProductListType listType;
  final String parameters;

  /// Page size at query time.
  final int? pageSize;

  /// Page number at query time.
  final int? pageNumber;

  /// Language at query time.
  final OpenFoodFactsLanguage? language;

  /// Country at query time.
  final OpenFoodFactsCountry? country;

  /// ProductType at query time.
  final ProductType? productType;

  /// "Total size" returned by the query.
  int totalSize = 0;

  final List<String> _barcodes = <String>[];

  List<String> get barcodes => _barcodes;

  bool isEmpty() => _barcodes.isEmpty;

  /// Removes a barcode from the list
  ///
  /// Returns false if not already in the list
  /// Don't forget to update the database afterwards
  bool remove(final String barcode) {
    if (!_barcodes.contains(barcode)) {
      return false;
    }
    _barcodes.remove(barcode);
    return true;
  }

  /// Sets all products with the same order as the input list
  void setAll(final List<Product> products) {
    final List<String> barcodes = <String>[];
    for (final Product product in products) {
      final String barcode = product.barcode!;
      barcodes.add(barcode);
    }
    set(barcodes);
  }

  void set(final Iterable<String> barcodes) {
    _barcodes.clear();
    _barcodes.addAll(barcodes);
  }

  List<String> getList() {
    final List<String> result = <String>[];
    final Iterable<String> barcodes = _isReversed()
        ? _barcodes.reversed
        : _barcodes;
    result.addAll(barcodes);
    return result;
  }

  bool _isReversed() {
    switch (listType) {
      case ProductListType.HTTP_SEARCH_KEYWORDS:
      case ProductListType.HTTP_SEARCH_CATEGORY:
      case ProductListType.HTTP_USER_CONTRIBUTOR:
      case ProductListType.HTTP_USER_INFORMER:
      case ProductListType.HTTP_USER_PHOTOGRAPHER:
      case ProductListType.HTTP_USER_TO_BE_COMPLETED:
      case ProductListType.HTTP_ALL_TO_BE_COMPLETED:
      case ProductListType.USER:
        return false;
      case ProductListType.SCAN_SESSION:
      case ProductListType.SCAN_HISTORY:
      case ProductListType.HISTORY:
        return true;
    }
  }

  String getParametersKey() {
    switch (listType) {
      case ProductListType.SCAN_SESSION:
      case ProductListType.SCAN_HISTORY:
      case ProductListType.HISTORY:
      case ProductListType.USER:
        return parameters;
      case ProductListType.HTTP_SEARCH_KEYWORDS:
      case ProductListType.HTTP_SEARCH_CATEGORY:
      case ProductListType.HTTP_USER_CONTRIBUTOR:
      case ProductListType.HTTP_USER_INFORMER:
      case ProductListType.HTTP_USER_PHOTOGRAPHER:
      case ProductListType.HTTP_USER_TO_BE_COMPLETED:
      case ProductListType.HTTP_ALL_TO_BE_COMPLETED:
        return '$parameters'
            ',$pageSize'
            ',$pageNumber'
            ',${language?.code ?? ''}'
            ',${country?.offTag ?? ''}'
            '${productType == null || productType == ProductType.food ? '' : ',${productType!.offTag}'}';
    }
  }

  /// Can be edited or renamed
  bool get isEditable => listType == ProductListType.USER;
}
