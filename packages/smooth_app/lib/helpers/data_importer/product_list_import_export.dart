import 'dart:convert';

import 'package:openfoodfacts/model/parameter/BarcodeParameter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Import / Export of product lists (with or without JSON).
/// All lists are composed of barcodes, where we support history and user lists
class ProductListImportExport {
  /// With a big history, and to limit the size and duration of a single request,
  /// we call multiple times the API
  static const int MAX_PRODUCTS_PER_REQUEST = 250;

  static const String TMP_IMPORT = '''
  {"history":{
  "barcodes":["3274080005003", "7622210449283"]},
  "user_lists":{
  "my awesome list":{"barcodes":["5449000000996", "3017620425035"]},
  "saved for later":{"barcodes":["3175680011480", "1234567891"]}
  }}''';

  Future<bool> importFromJSON(
    final String jsonEncoded,
    final LocalDatabase localDatabase,
  ) async {
    try {
      final dynamic map = json.decode(jsonEncoded);
      if (map is! Map<String, dynamic>) {
        throw Exception('Expected Map<String, dynamic>');
      }

      return import(ImportableLists(map), localDatabase);
    } catch (err) {
      return false;
    }
  }

  Future<bool> import(
    final ImportableLists lists,
    final LocalDatabase localDatabase,
  ) async {
    try {
      final Set<String> inputBarcodes = lists.extractBarcodes();
      final List<Product> products = <Product>[];

      // To prevent a too long request, we limit the barcodes to fetch
      for (final Iterable<String> barcodes
          in inputBarcodes.split(MAX_PRODUCTS_PER_REQUEST)) {
        products.addAll(await _fetchProducts(barcodes));
      }

      await _saveNewProducts(localDatabase, products);
      await _saveNewProductsToLists(localDatabase, lists, products);

      return true;
    } catch (err) {
      return false;
    }
  }

  /// Fetches Products from the API
  Future<List<Product>> _fetchProducts(
    Iterable<String> barcodes,
  ) async {
    final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
      ProductQuery.getUser(),
      ProductSearchQueryConfiguration(
        fields: ProductQuery.fields,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
        parametersList: <Parameter>[
          BarcodeParameter.list(barcodes.toList(growable: false)),
        ],
      ),
    );

    return searchResult.products ?? <Product>[];
  }

  /// Stores products in the database
  Future<void> _saveNewProducts(
    LocalDatabase localDatabase,
    List<Product> products,
  ) async {
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final Map<String, Product> productsToAdd = <String, Product>{};
    for (final Product product in products) {
      productsToAdd[product.barcode!] = product;
      await daoProduct.put(product);
    }
  }

  /// Stores lists with their products in the database
  /// History & user's lists are supported
  Future<void> _saveNewProductsToLists(
    LocalDatabase localDatabase,
    ImportableLists lists,
    List<Product> products,
  ) async {
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    await _importHistory(lists.history, products, daoProductList);
    await _importUserLists(lists.userLists, products, daoProductList);
  }

  Future<void> _importHistory(
    ImportableList? list,
    List<Product> fetchedProducts,
    DaoProductList daoProductList,
  ) async {
    return _importList(
      list,
      ProductList.history(),
      fetchedProducts,
      daoProductList,
    );
  }

  Future<List<void>> _importUserLists(
    ImportableUserLists? lists,
    List<Product> fetchedProducts,
    DaoProductList daoProductList,
  ) async {
    if (lists?.lists.isNotEmpty != true) {
      return <void>[];
    }

    final List<Future<void>> tasks = <Future<void>>[];
    for (final String key in lists!.lists.keys) {
      tasks.add(_importList(
        lists.lists[key],
        ProductList.user(key),
        fetchedProducts,
        daoProductList,
      ));
    }

    return Future.wait<void>(tasks);
  }

  Future<void> _importList(
    ImportableList? list,
    ProductList productList,
    List<Product> fetchedProducts,
    DaoProductList daoProductList,
  ) async {
    if (list == null) {
      return;
    }

    productList.set(list.barcodes);
    await DaoProduct(daoProductList.localDatabase).putAll(fetchedProducts);
    return daoProductList.put(productList);
  }
}

class ImportableLists {
  ImportableLists(
    Map<String, dynamic> json,
  )   : history = json['history'] is Map
            ? ImportableList(json['history'] as Map<String, dynamic>)
            : null,
        userLists = json['user_lists'] is Map
            ? ImportableUserLists(json['user_lists'] as Map<String, dynamic>)
            : null;

  final ImportableList? history;
  final ImportableUserLists? userLists;

  /// Extract barcodes from history and user's lists to have a Set (= unique)
  /// of all them
  Set<String> extractBarcodes() {
    final Set<String> barcodes = <String>{};

    barcodes.addAllSafe(history?.barcodes);
    barcodes.addAllSafe(userLists?.extractBarcodes());

    return barcodes;
  }
}

class ImportableUserLists {
  ImportableUserLists(
    Map<String, dynamic> json,
  ) : lists = json.map(
          (String key, dynamic value) => MapEntry<String, ImportableList>(
            key,
            ImportableList(json[key] as Map<String, dynamic>),
          ),
        );

  final Map<String, ImportableList> lists;

  /// Extract barcodes from all lists to have a Set (= unique) of all them
  Set<String> extractBarcodes() {
    final Set<String> barcodes = <String>{};

    for (final String key in lists.keys) {
      barcodes.addAllSafe(lists[key]?.barcodes);
    }

    return barcodes;
  }
}

class ImportableList {
  ImportableList(
    Map<String, dynamic> json,
  ) : barcodes = (json['barcodes'] as List<dynamic>).cast<String>();

  final List<String> barcodes;
}
