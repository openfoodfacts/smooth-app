import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/bulk_deletable.dart';
import 'package:smooth_app/database/bulk_manager.dart';
import 'package:smooth_app/database/dao_product_last_access.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaoProduct extends AbstractSqlDao implements BulkDeletable {
  DaoProduct(super.localDatabase);

  static const String _TABLE_PRODUCT = 'gzipped_product';
  static const String _TABLE_PRODUCT_COLUMN_BARCODE = 'barcode';
  static const String _TABLE_PRODUCT_COLUMN_GZIPPED_JSON =
      'encoded_gzipped_json';
  static const String _TABLE_PRODUCT_COLUMN_LAST_UPDATE = 'last_update';
  static const String _TABLE_PRODUCT_COLUMN_LANGUAGE = 'lc';

  static const List<String> _columns = <String>[
    _TABLE_PRODUCT_COLUMN_BARCODE,
    _TABLE_PRODUCT_COLUMN_GZIPPED_JSON,
    _TABLE_PRODUCT_COLUMN_LAST_UPDATE,
    _TABLE_PRODUCT_COLUMN_LANGUAGE,
  ];

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('create table $_TABLE_PRODUCT('
          // cf. https://www.sqlite.org/lang_conflict.html
          '$_TABLE_PRODUCT_COLUMN_BARCODE TEXT PRIMARY KEY on conflict replace'
          ',$_TABLE_PRODUCT_COLUMN_GZIPPED_JSON BLOB NOT NULL'
          ',$_TABLE_PRODUCT_COLUMN_LAST_UPDATE INT NOT NULL'
          ')');
    }
    if (oldVersion < 4) {
      await db.execute('alter table $_TABLE_PRODUCT add column '
          '$_TABLE_PRODUCT_COLUMN_LANGUAGE TEXT');
    }
  }

  /// Returns the [Product] that matches the [barcode], or null.
  Future<Product?> get(final String barcode) async {
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      _TABLE_PRODUCT,
      columns: _columns,
      where: '$_TABLE_PRODUCT_COLUMN_BARCODE = ?',
      whereArgs: <String>[barcode],
    );
    // O or 1 row expected
    for (final Map<String, dynamic> row in queryResults) {
      return _getProductFromQueryResult(row);
    }
    return null;
  }

  /// Returns the [Product]s that match the [barcodes].
  Future<Map<String, Product>> getAll(final List<String> barcodes) async {
    final Map<String, Product> result = <String, Product>{};
    if (barcodes.isEmpty) {
      return result;
    }
    for (int start = 0;
        start < barcodes.length;
        start += BulkManager.SQLITE_MAX_VARIABLE_NUMBER) {
      final int size = min(
        barcodes.length - start,
        BulkManager.SQLITE_MAX_VARIABLE_NUMBER,
      );
      final List<Map<String, dynamic>> queryResults =
          await localDatabase.database.query(
        _TABLE_PRODUCT,
        columns: _columns,
        where: '$_TABLE_PRODUCT_COLUMN_BARCODE in(? ${',?' * (size - 1)})',
        whereArgs: barcodes.sublist(start, start + size),
      );
      for (final Map<String, dynamic> row in queryResults) {
        result[row[_TABLE_PRODUCT_COLUMN_BARCODE] as String] =
            _getProductFromQueryResult(row);
      }
    }
    return result;
  }

  /// Returns the local products split by product type.
  Future<Map<ProductType, List<String>>> getProductTypes(
    final List<String> barcodes,
  ) async {
    final Map<ProductType, List<String>> result = <ProductType, List<String>>{};
    if (barcodes.isEmpty) {
      return result;
    }
    for (int start = 0;
        start < barcodes.length;
        start += BulkManager.SQLITE_MAX_VARIABLE_NUMBER) {
      final int size = min(
        barcodes.length - start,
        BulkManager.SQLITE_MAX_VARIABLE_NUMBER,
      );
      final List<Map<String, dynamic>> queryResults =
          await localDatabase.database.query(
        _TABLE_PRODUCT,
        columns: _columns,
        where: '$_TABLE_PRODUCT_COLUMN_BARCODE in(? ${',?' * (size - 1)})',
        whereArgs: barcodes.sublist(start, start + size),
      );
      for (final Map<String, dynamic> row in queryResults) {
        final Product product = _getProductFromQueryResult(row);
        final ProductType productType = product.productType ?? ProductType.food;
        List<String>? barcodes = result[productType];
        if (barcodes == null) {
          barcodes = <String>[];
          result[productType] = barcodes;
        }
        barcodes.add(product.barcode!);
      }
    }
    return result;
  }

  /// Returns all the local products split by a function.
  Future<Map<String, List<String>>> splitAllProducts(
    final String Function(Product) splitFunction,
  ) async {
    final Map<String, List<String>> result = <String, List<String>>{};
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      _TABLE_PRODUCT,
      columns: _columns,
    );
    for (final Map<String, dynamic> row in queryResults) {
      final Product product = _getProductFromQueryResult(row);
      final String splitValue = splitFunction(product);
      List<String>? barcodes = result[splitValue];
      if (barcodes == null) {
        barcodes = <String>[];
        result[splitValue] = barcodes;
      }
      barcodes.add(product.barcode!);
    }
    return result;
  }

  Future<void> put(
    final Product product,
    final OpenFoodFactsLanguage language, {
    required final ProductType productType,
  }) async =>
      putAll(
        <Product>[product],
        language,
        productType: productType,
      );

  /// Replaces products in database
  Future<void> putAll(
    final Iterable<Product> products,
    final OpenFoodFactsLanguage language, {
    required final ProductType productType,
  }) async {
    for (final Product product in products) {
      // in case the server product has no product type, which shouldn't happen
      // in the future
      product.productType ??= productType;
    }
    await localDatabase.database.transaction(
      (final Transaction transaction) async => _bulkReplaceLoop(
        transaction,
        products,
        language,
      ),
    );
  }

  Future<List<String>> getAllKeys() async {
    final List<String> result = <String>[];
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      _TABLE_PRODUCT,
      columns: <String>[
        _TABLE_PRODUCT_COLUMN_BARCODE,
      ],
    );
    if (queryResults.isEmpty) {
      return result;
    }
    for (final Map<String, dynamic> row in queryResults) {
      result.add(row[_TABLE_PRODUCT_COLUMN_BARCODE] as String);
    }
    return result;
  }

  /// Replaces product data in bulk mode.
  ///
  /// Unfortunately it's a replace (=delete if already exists, then insert),
  /// not an upsert (=insert if possible, or update if already exists).
  /// "upsert" is not really supported for the moment on sqflite.
  /// The direct impact is we shouldn't use foreign key constraints on
  /// `product.barcode`.
  Future<void> _bulkReplaceLoop(
    final DatabaseExecutor databaseExecutor,
    final Iterable<Product> products,
    final OpenFoodFactsLanguage language,
  ) async {
    final int lastUpdate = LocalDatabase.nowInMillis();
    final BulkManager bulkManager = BulkManager();
    final List<dynamic> insertParameters = <dynamic>[];
    for (final Product product in products) {
      insertParameters.add(product.barcode);
      insertParameters.add(
        Uint8List.fromList(
          gzip.encode(utf8.encode(jsonEncode(product.toJson()))),
        ),
      );
      insertParameters.add(lastUpdate);
      insertParameters.add(language.offTag);
    }
    await bulkManager.insert(
      bulkInsertable: this,
      parameters: insertParameters,
      databaseExecutor: databaseExecutor,
    );
  }

  @override
  List<String> getInsertColumns() => _columns;

  @override
  String getDeleteWhere(final List<dynamic> deleteWhereArgs) =>
      '$_TABLE_PRODUCT_COLUMN_BARCODE in (?${',?' * (deleteWhereArgs.length - 1)})';

  @override
  String getTableName() => _TABLE_PRODUCT;

  Product _getProductFromQueryResult(final Map<String, dynamic> row) {
    final Uint8List compressed =
        row[_TABLE_PRODUCT_COLUMN_GZIPPED_JSON] as Uint8List;
    final String encodedJson = utf8.decode(gzip.decode(compressed.toList()));
    final Map<String, dynamic> decodedJson =
        json.decode(encodedJson) as Map<String, dynamic>;
    return Product.fromJson(decodedJson);
  }

  /// For developers with stats in mind only.
  Future<void> printStats({final bool verbose = false}) async {
    final List<String> barcodes = await getAllKeys();
    debugPrint('number of barcodes: ${barcodes.length}');
    final Map<String, Product> map = await getAll(barcodes);
    int jsonLength = 0;
    for (final Product product in map.values) {
      jsonLength += utf8.encode(jsonEncode(product.toJson())).length;
    }
    debugPrint('json length: $jsonLength');
    final int gzippedLength = Sqflite.firstIntValue(
      await localDatabase.database.rawQuery(
        'select sum(length($_TABLE_PRODUCT_COLUMN_GZIPPED_JSON))'
        ' from $_TABLE_PRODUCT',
      ),
    )!;
    debugPrint('gzipped length: $gzippedLength');
    if (!verbose) {
      return;
    }
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.rawQuery(
      'select'
      ' $_TABLE_PRODUCT_COLUMN_BARCODE'
      ', length($_TABLE_PRODUCT_COLUMN_GZIPPED_JSON) as mylength'
      ' from $_TABLE_PRODUCT',
    );
    debugPrint('Product by product');
    debugPrint('barcode;gzipped;string;factor');
    for (final Map<String, dynamic> row in queryResults) {
      final String barcode = row[_TABLE_PRODUCT_COLUMN_BARCODE] as String;
      final int asString =
          utf8.encode(jsonEncode(map[barcode]!.toJson())).length;
      final int asZipped = row['mylength'] as int;
      final double factor = (asString * 1.0) / asZipped;
      debugPrint('$barcode;$asZipped;$asString;$factor');
    }
  }

  /// Get the total number of products in the database
  Future<Map<ProductType, int>> getTotalNoOfProducts() async {
    final Map<ProductType, int> result = <ProductType, int>{};
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      _TABLE_PRODUCT,
      columns: _columns,
    );
    for (final Map<String, dynamic> row in queryResults) {
      final Product product = _getProductFromQueryResult(row);
      final ProductType productType = product.productType ?? ProductType.food;
      final int? count = result[productType];
      result[productType] = 1 + (count ?? 0);
    }
    return result;
  }

  /// Get the estimated total size of the database in MegaBytes
  Future<double> getEstimatedTotalSizeInMB() async {
    // We get the estimated size of the database in bytes
    // by summing the size of the gzipped json column and
    // the size of the barcode column and last update column
    final int? estimatedDataSize = Sqflite.firstIntValue(
      await localDatabase.database.rawQuery('''
        select sum(length($_TABLE_PRODUCT_COLUMN_BARCODE)) +
        sum(length($_TABLE_PRODUCT_COLUMN_LAST_UPDATE)) + 
        sum(length($_TABLE_PRODUCT_COLUMN_LANGUAGE)) + 
        sum(length($_TABLE_PRODUCT_COLUMN_GZIPPED_JSON))
        from $_TABLE_PRODUCT
        '''),
    );
    return double.parse(
      ((estimatedDataSize ?? 0) / ~1024 / ~1024).toStringAsFixed(2),
    );
  }

  /// Delete all products from the database
  Future<int> deleteAll() async {
    // We return the number of rows deleted ie the number of products deleted
    return localDatabase.database.delete(_TABLE_PRODUCT);
  }

  /// Returns the most recently locally accessed products with wrong language.
  ///
  /// Typical use-case: when the user changes the app language, downloading
  /// incrementally all products with a different (or null) download language.
  /// We need [excludeBarcodes] because in some rare cases products may not be
  /// found anymore on the server - it happened to me with obviously fake test
  /// products being probably wiped out.
  Future<List<String>> getTopProductsToTranslate(
    final OpenFoodFactsLanguage language, {
    required final int limit,
    required final List<String> excludeBarcodes,
    required final ProductType productType,
  }) async {
    /// Unfortunately, some SQFlite implementations don't support "nulls last"
    String getRawQuery(final bool withNullsLast) =>
        'select p.$_TABLE_PRODUCT_COLUMN_GZIPPED_JSON '
        'from'
        ' $_TABLE_PRODUCT p'
        ' left outer join ${DaoProductLastAccess.TABLE} a'
        '  on p.$_TABLE_PRODUCT_COLUMN_BARCODE = a.${DaoProductLastAccess.COLUMN_BARCODE} '
        'where'
        ' p.$_TABLE_PRODUCT_COLUMN_LANGUAGE is null'
        ' or p.$_TABLE_PRODUCT_COLUMN_LANGUAGE != ? '
        'order by a.${DaoProductLastAccess.COLUMN_LAST_ACCESS} desc ${withNullsLast ? 'nulls last' : ''} ';

    List<Map<String, dynamic>> queryResults = <Map<String, dynamic>>[];
    try {
      queryResults = await localDatabase.database.rawQuery(
        getRawQuery(true),
        <Object>[
          language.offTag,
        ],
      );
    } catch (e) {
      if (!e.toString().startsWith(
            'DatabaseException(near "nulls": syntax error (code 1 SQLITE_ERROR[1])',
          )) {
        rethrow;
      }
      queryResults = await localDatabase.database.rawQuery(
        getRawQuery(false),
        <Object>[
          language.offTag,
        ],
      );
    }

    final List<String> result = <String>[];

    for (final Map<String, dynamic> row in queryResults) {
      final Product product = _getProductFromQueryResult(row);
      final String barcode = product.barcode!;
      if (excludeBarcodes.contains(barcode)) {
        continue;
      }
      if ((product.productType ?? ProductType.food) != productType) {
        continue;
      }
      result.add(barcode);
      if (result.length == limit) {
        break;
      }
    }

    return result;
  }

  /// Sets the language of all products to null.
  ///
  /// This is useful to refresh the whole database, as products without language
  /// are easy to detect. And therefore we can say "refresh all the products
  /// with a language null or different from the current app language", and use
  /// the same mechanism as "switch language and refresh products accordingly".
  Future<int> clearAllLanguages() async => localDatabase.database.update(
        _TABLE_PRODUCT,
        <String, Object?>{_TABLE_PRODUCT_COLUMN_LANGUAGE: null},
      );
}
