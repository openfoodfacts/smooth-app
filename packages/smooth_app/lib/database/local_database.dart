import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:openfoodfacts/model/Product.dart';

class LocalDatabase extends ChangeNotifier {
  LocalDatabase._(final Database database) : _database = database;

  final Database _database;

  static const String _TABLE_PRODUCT = 'product';
  static const String _TABLE_PRODUCT_COLUMN_BARCODE = 'barcode';
  static const String _TABLE_PRODUCT_COLUMN_JSON = 'encoded_json';
  static const String _TABLE_PRODUCT_COLUMN_TIMESTAMP = 'last_upsert';

  static Future<LocalDatabase> getLocalDatabase() async {
    final String databasesRootPath = await getDatabasesPath();
    final String databasePath = join(databasesRootPath, 'smoothie.db');

    final Database database = await openDatabase(
      databasePath,
      version: 1,
      singleInstance: true,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return LocalDatabase._(database);
  }

  static FutureOr<void> _onCreate(final Database db, final int version) async {
    await db.execute('create table $_TABLE_PRODUCT('
        '$_TABLE_PRODUCT_COLUMN_BARCODE TEXT PRIMARY KEY,'
        '$_TABLE_PRODUCT_COLUMN_JSON TEXT NOT NULL,'
        '$_TABLE_PRODUCT_COLUMN_TIMESTAMP INT NOT NULL'
        ')');
  }

  static FutureOr<void> _onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    // not relevant for the moment, we only have 1 version of the database
  }

  static int _nowInMillis() => DateTime.now().millisecondsSinceEpoch;

  Future<TableStats> getTableStats() async {
    const String COLUMN_COUNT = 'mycount';
    const String COLUMN_MIN = 'mymin';
    const String COLUMN_MAX = 'mymax';

    final List<Map<String, dynamic>> queryResult = await _database.query(
      _TABLE_PRODUCT,
      columns: <String>[
        'count(*) as $COLUMN_COUNT',
        'max($_TABLE_PRODUCT_COLUMN_TIMESTAMP) as $COLUMN_MAX',
        'min($_TABLE_PRODUCT_COLUMN_TIMESTAMP) as $COLUMN_MIN',
      ],
    );
    if (queryResult.isEmpty || queryResult.length > 1) {
      // very very unlikely to happen
      throw Exception('No stats for table $_TABLE_PRODUCT');
    }
    final Map<String, dynamic> uniqueRow = queryResult[0];
    return TableStats(
      count: uniqueRow[COLUMN_COUNT] as int,
      minTimestamp: uniqueRow[COLUMN_MIN] as int,
      maxTimestamp: uniqueRow[COLUMN_MAX] as int,
    );
  }

  Future<Product> getProduct(final String barcode) async {
    final List<Map<String, dynamic>> queryResult = await _database.query(
      _TABLE_PRODUCT,
      columns: <String>[_TABLE_PRODUCT_COLUMN_JSON],
      where: '$_TABLE_PRODUCT_COLUMN_BARCODE = ?',
      whereArgs: <String>[barcode],
    );
    if (queryResult.isEmpty) {
      // not found
      return null;
    }
    if (queryResult.length > 1) {
      // very very unlikely to happen
      throw Exception('Several products with the same barcode $barcode');
    }
    return _getProductFromQueryResult(queryResult[0]);
  }

  Future<Map<String, Product>> getProducts(final List<String> barcodes) async {
    final Map<String, Product> result = <String, Product>{};
    if (barcodes == null || barcodes.isEmpty) {
      return result;
    }
    final List<Map<String, dynamic>> queryResults = await _database.query(
      _TABLE_PRODUCT,
      columns: <String>[
        _TABLE_PRODUCT_COLUMN_BARCODE,
        _TABLE_PRODUCT_COLUMN_JSON,
      ],
      where:
          '$_TABLE_PRODUCT_COLUMN_BARCODE in(? ${',?' * (barcodes.length - 1)})',
      whereArgs: barcodes,
    );
    if (queryResults.isEmpty) {
      return result;
    }
    for (final Map<String, dynamic> row in queryResults) {
      result[row[_TABLE_PRODUCT_COLUMN_BARCODE] as String] =
          _getProductFromQueryResult(row);
    }
    return result;
  }

  Future<void> putProduct(final Product product) async =>
      await _putProduct(product, _database);

  Future<void> putProducts(final List<Product> products) async =>
      await _database.transaction((final Transaction transaction) async {
        for (final Product product in products) {
          await _putProduct(product, transaction);
        }
      });

  static Future<void> _putProduct(
    final Product product,
    final DatabaseExecutor databaseExecutor,
  ) async =>
      await databaseExecutor.insert(
        _TABLE_PRODUCT,
        <String, dynamic>{
          _TABLE_PRODUCT_COLUMN_BARCODE: product.barcode,
          _TABLE_PRODUCT_COLUMN_JSON: json.encode(product.toJson()),
          _TABLE_PRODUCT_COLUMN_TIMESTAMP: _nowInMillis(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Product _getProductFromQueryResult(final Map<String, dynamic> row) {
    final String encodedJson = row[_TABLE_PRODUCT_COLUMN_JSON] as String;
    final Map<String, dynamic> decodedJson =
        json.decode(encodedJson) as Map<String, dynamic>;
    return Product.fromJson(decodedJson);
  }
}

class TableStats {
  TableStats({
    this.count,
    this.minTimestamp,
    this.maxTimestamp,
  });

  final int count;
  final int minTimestamp;
  final int maxTimestamp;

  @override
  String toString() => 'TableStats('
      'count: $count'
      ','
      'minTimestamp: ${DateTime.fromMillisecondsSinceEpoch(minTimestamp)}'
      ','
      'maxTimestamp: ${DateTime.fromMillisecondsSinceEpoch(maxTimestamp)}'
      ')';
}
