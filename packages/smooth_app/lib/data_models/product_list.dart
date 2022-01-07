import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';

enum ProductListType {
  /// API search for [PnnsGroup2Filter] related food groups
  HTTP_SEARCH_GROUP,

  /// API search by [SearchTerms] keywords
  HTTP_SEARCH_KEYWORDS,

  /// API search for [CategoryProductQuery] category
  HTTP_SEARCH_CATEGORY,

  /// Current scan session; can be easily cleared by the end-user
  SCAN_SESSION,

  /// History of products seen by the end-user
  HISTORY,
}

extension ProductListTypeExtension on ProductListType {
  static const Map<ProductListType, String> _keys = <ProductListType, String>{
    ProductListType.HTTP_SEARCH_GROUP: 'http/search/group',
    ProductListType.HTTP_SEARCH_KEYWORDS: 'http/search/keywords',
    ProductListType.HTTP_SEARCH_CATEGORY: 'http/search/category',
    ProductListType.SCAN_SESSION: 'scan_session',
    ProductListType.HISTORY: 'history',
  };

  String get key => _keys[this]!;
}

class ProductList {
  ProductList._({required this.listType, this.parameters = ''});

  ProductList.keywordSearch(final String keywords)
      : this._(
          listType: ProductListType.HTTP_SEARCH_KEYWORDS,
          parameters: keywords,
        );

  ProductList.categorySearch(final String category)
      : this._(
          listType: ProductListType.HTTP_SEARCH_CATEGORY,
          parameters: category,
        );

  ProductList.groupSearch(final PnnsGroup2 group)
      : this._(
          listType: ProductListType.HTTP_SEARCH_GROUP,
          parameters: group.id,
        );

  ProductList.history() : this._(listType: ProductListType.HISTORY);

  ProductList.scanSession() : this._(listType: ProductListType.SCAN_SESSION);

  final ProductListType listType;
  final String parameters;

  final List<String> _barcodes = <String>[];
  final Map<String, Product> _products = <String, Product>{};

  /// API search for [PnnsGroup2Filter] related food groups
  static const String LIST_TYPE_HTTP_SEARCH_GROUP = 'http/search/group';

  /// API search by [SearchTerms] keywords
  static const String LIST_TYPE_HTTP_SEARCH_KEYWORDS = 'http/search/keywords';

  /// API search for [CategoryProductQuery] category
  static const String LIST_TYPE_HTTP_SEARCH_CATEGORY = 'http/search/category';

  /// Current scan session; can be easily cleared by the end-user
  static const String LIST_TYPE_SCAN_SESSION = 'scan_session';

  /// History of products seen by the end-user
  static const String LIST_TYPE_HISTORY = 'history';

  List<String> get barcodes => _barcodes;

  bool isEmpty() => _barcodes.isEmpty;

  Product getProduct(final String barcode) => _products[barcode]!;

  bool isSameAs(final ProductList other) =>
      listType == other.listType && parameters == other.parameters;

  void refresh(final Product product) {
    final String? barcode = product.barcode;
    if (barcode == null) {
      throw Exception('null barcode');
    }
    _products[barcode] = product;
  }

  /// Removes a barcode from the list
  ///
  /// Returns false if not already in the list
  /// Don't forget to update the database afterwards
  bool remove(final String barcode) {
    if (!_barcodes.contains(barcode)) {
      return false;
    }
    _barcodes.remove(barcode);
    _products.remove(barcode);
    return true;
  }

  /// Sets all products with the same order as the input list
  void setAll(final List<Product> products) {
    final List<String> barcodes = <String>[];
    final Map<String, Product> productMap = <String, Product>{};
    for (final Product product in products) {
      final String barcode = product.barcode!;
      barcodes.add(barcode);
      productMap[barcode] = product;
    }
    set(barcodes, productMap);
  }

  void set(
    final List<String> barcodes,
    final Map<String, Product> products,
  ) {
    _barcodes.clear();
    _products.clear();
    _products.addAll(products);
    _barcodes.addAll(barcodes);
  }

  List<Product> getList() {
    final List<Product> result = <Product>[];
    final Iterable<String> barcodes =
        _isReversed() ? _barcodes.reversed : _barcodes;
    for (final String barcode in barcodes) {
      final Product? product = _products[barcode];
      if (product == null) {
        throw Exception('no product for barcode $barcode');
      }
      result.add(product);
    }
    return result;
  }

  bool _isReversed() {
    switch (listType) {
      case ProductListType.HTTP_SEARCH_GROUP:
      case ProductListType.HTTP_SEARCH_KEYWORDS:
      case ProductListType.HTTP_SEARCH_CATEGORY:
        return false;
      case ProductListType.SCAN_SESSION:
      case ProductListType.HISTORY:
        return true;
    }
  }
}
