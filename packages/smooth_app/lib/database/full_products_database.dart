import 'dart:io';

import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/PnnsGroupQueryConfiguration.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class FullProductsDatabase {
  FullProductsDatabase() {
    factory = databaseFactoryIo;
  }

  DatabaseFactory factory;
  bool useLocalDatabase = false;

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
    ProductField.LANGUAGE
  ];

  Future<bool> checkAndFetchProduct(String barcode) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, 'full_products_database.db');
    final Database database = await factory.openDatabase(path);

    final StoreRef<dynamic, dynamic> store = StoreRef<dynamic, dynamic>.main();

    if (useLocalDatabase && await store.record(barcode).exists(database)) {
      return true;
    }

    final ProductQueryConfiguration configuration =
        ProductQueryConfiguration(barcode,
            fields: fields,
            language: OpenFoodFactsLanguage.ENGLISH);

    final ProductResult result =
        await OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
      return await saveProduct(result.product);
    }

    return false;
  }

  Future<List<Product>> queryPnnsGroup(PnnsGroup2 group, {int page = 1}) async {
    final PnnsGroupQueryConfiguration configuration =
        PnnsGroupQueryConfiguration(group,
            fields: fields,
            page: page,
            language: OpenFoodFactsLanguage.ENGLISH);

     final SearchResult result = await OpenFoodAPIClient.queryPnnsGroup(SMOOTH_USER, configuration);

     result.products.forEach(saveProduct);

     return result.products;
  }

  Future<List<Product>> queryProductsFromKeyword(String keyword) async {
    final ProductSearchQueryConfiguration configuration =
    ProductSearchQueryConfiguration(
        fields: fields,
        parametersList: <Parameter>[
          const PageSize(size: 500),
          TagFilter(tagType: 'categories', contains: true, tagName: keyword)
        ],
        language: OpenFoodFactsLanguage.ENGLISH);

    final SearchResult result = await OpenFoodAPIClient.searchProducts(SMOOTH_USER, configuration);

    result.products.forEach(saveProduct);

    return result.products;
  }

  Future<bool> saveProduct(Product newProduct) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, 'full_products_database.db');
    final Database database = await factory.openDatabase(path);

    print(newProduct.toJson());
    try {
      final StoreRef<dynamic, dynamic> store =
          StoreRef<dynamic, dynamic>.main();
      await store.record(newProduct.barcode).put(database, newProduct.toJson());
      return true;
    } catch (e) {
      print('An error occurred while saving product to local database : $e');
      return false;
    }
  }

  Future<Product> getProduct(String barcode) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, 'full_products_database.db');
    final Database database = await factory.openDatabase(path);

    final StoreRef<dynamic, dynamic> store = StoreRef<dynamic, dynamic>.main();
    final Map<String, dynamic> jsonProduct =
        await store.record(barcode).get(database) as Map<String, dynamic>;

    if (jsonProduct != null) {
      print(jsonProduct);
      return Product.fromJson(jsonProduct);
    }

    return null;
  }
}
