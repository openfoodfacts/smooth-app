import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/bulk_deletable.dart';
import 'package:smooth_app/database/bulk_manager.dart';
import 'package:smooth_app/database/dao_product_migration.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaoProduct extends AbstractSqlDao
    implements BulkDeletable, DaoProductMigrationDestination {
  DaoProduct(super.localDatabase);

  static const String _TABLE_PRODUCT = 'gzipped_product';
  static const String _TABLE_PRODUCT_COLUMN_BARCODE = 'barcode';
  static const String _TABLE_PRODUCT_COLUMN_GZIPPED_JSON =
      'encoded_gzipped_json';
  static const String _TABLE_PRODUCT_COLUMN_LAST_UPDATE = 'last_update';

  static const List<String> _columns = <String>[
    _TABLE_PRODUCT_COLUMN_BARCODE,
    _TABLE_PRODUCT_COLUMN_GZIPPED_JSON,
    _TABLE_PRODUCT_COLUMN_LAST_UPDATE,
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

  Future<void> put(final Product product) async => putAll(<Product>[product]);

  /// Replaces products in database
  @override
  Future<void> putAll(final Iterable<Product> products) async =>
      localDatabase.database.transaction(
        (final Transaction transaction) async =>
            _bulkReplaceLoop(transaction, products),
      );

  @override
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
}
