import 'dart:async';
import 'dart:convert';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:openfoodfacts/model/Product.dart';

class DaoProduct {
  DaoProduct(this.localDatabase);

  final LocalDatabase localDatabase;

  static const String TABLE_PRODUCT = 'product';
  static const String TABLE_PRODUCT_COLUMN_BARCODE = 'barcode';
  static const String _TABLE_PRODUCT_COLUMN_JSON = 'encoded_json';

  static const String _WHERE_PK = '$TABLE_PRODUCT_COLUMN_BARCODE = ?';

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 1) {
      await db.execute('create table $TABLE_PRODUCT('
          '$TABLE_PRODUCT_COLUMN_BARCODE TEXT PRIMARY KEY,'
          '$_TABLE_PRODUCT_COLUMN_JSON TEXT NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL'
          ')');
    }
  }

  Future<int> getLastUpdate(final String barcode) =>
      _getLastUpdate(barcode, localDatabase.database);

  Future<Product> get(final String barcode) async {
    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.query(
      TABLE_PRODUCT,
      columns: <String>[_TABLE_PRODUCT_COLUMN_JSON],
      where: _WHERE_PK,
      whereArgs: <dynamic>[barcode],
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

  Future<Map<String, Product>> getAll(final List<String> barcodes) async {
    final Map<String, Product> result = <String, Product>{};
    if (barcodes == null || barcodes.isEmpty) {
      return result;
    }
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      TABLE_PRODUCT,
      columns: <String>[
        TABLE_PRODUCT_COLUMN_BARCODE,
        _TABLE_PRODUCT_COLUMN_JSON,
      ],
      where:
          '$TABLE_PRODUCT_COLUMN_BARCODE in(? ${',?' * (barcodes.length - 1)})',
      whereArgs: barcodes,
    );
    if (queryResults.isEmpty) {
      return result;
    }
    for (final Map<String, dynamic> row in queryResults) {
      result[row[TABLE_PRODUCT_COLUMN_BARCODE] as String] =
          _getProductFromQueryResult(row);
    }
    return result;
  }

  Future<void> put(final Product product) async =>
      await _upsert(product, localDatabase.database);

  Future<void> putProducts(final List<Product> products) async {
    await localDatabase.database
        .transaction((final Transaction transaction) async {
      for (final Product product in products) {
        await _upsert(product, transaction);
      }
    });
  }

  /// Upsert clumsy implementation due to poor SQLite support by sqlflite
  /// (ConflictAlgorithm.replace is not an option because of FK cascade delete)
  static Future<bool> _upsert(
    final Product product,
    final DatabaseExecutor databaseExecutor,
  ) async {
    try {
      final int lastUpdate =
          await _getLastUpdate(product.barcode, databaseExecutor);
      if (lastUpdate != null) {
        final int nbRows = await _update(product, databaseExecutor);
        if (nbRows == 1) {
          // very expected result
          return true;
        }
      }
      return await _insert(product, databaseExecutor);
    } catch (e) {
      print('exception: $e');
    }
    return false;
  }

  static Future<bool> _insert(
    final Product product,
    final DatabaseExecutor databaseExecutor,
  ) async {
    try {
      await databaseExecutor.insert(
        TABLE_PRODUCT,
        <String, dynamic>{
          TABLE_PRODUCT_COLUMN_BARCODE: product.barcode,
          _TABLE_PRODUCT_COLUMN_JSON: json.encode(product.toJson()),
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
      );
      return true;
    } catch (e) {
      print('exception: $e');
    }
    return false;
  }

  static Future<int> _update(
    final Product product,
    final DatabaseExecutor databaseExecutor,
  ) async {
    try {
      return await databaseExecutor.update(
        TABLE_PRODUCT,
        <String, dynamic>{
          _TABLE_PRODUCT_COLUMN_JSON: json.encode(product.toJson()),
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
        where: _WHERE_PK,
        whereArgs: <dynamic>[product.barcode],
      );
    } catch (e) {
      print('exception: $e');
    }
    return 0;
  }

  static Future<int> _getLastUpdate(
    final String barcode,
    final DatabaseExecutor databaseExecutor,
  ) async {
    final List<Map<String, dynamic>> queryResult = await databaseExecutor.query(
      TABLE_PRODUCT,
      columns: <String>[LocalDatabase.COLUMN_TIMESTAMP],
      where: _WHERE_PK,
      whereArgs: <dynamic>[barcode],
    );
    if (queryResult.isEmpty) {
      // not found
      return null;
    }
    if (queryResult.length > 1) {
      // very very unlikely to happen
      throw Exception('Several products with the same barcode $barcode');
    }
    return queryResult.first[LocalDatabase.COLUMN_TIMESTAMP] as int;
  }

  Product _getProductFromQueryResult(final Map<String, dynamic> row) {
    final String encodedJson = row[_TABLE_PRODUCT_COLUMN_JSON] as String;
    final Map<String, dynamic> decodedJson =
        json.decode(encodedJson) as Map<String, dynamic>;
    return Product.fromJson(decodedJson);
  }
}
