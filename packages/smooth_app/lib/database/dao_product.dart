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

  Future<Product> get(final String barcode) async {
    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.query(
      TABLE_PRODUCT,
      columns: <String>[_TABLE_PRODUCT_COLUMN_JSON],
      where: '$TABLE_PRODUCT_COLUMN_BARCODE = ?',
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
      await _put(product, localDatabase.database);

  Future<void> putProducts(final List<Product> products) async =>
      await localDatabase.database
          .transaction((final Transaction transaction) async {
        for (final Product product in products) {
          await _put(product, transaction);
        }
      });

  static Future<void> _put(
    final Product product,
    final DatabaseExecutor databaseExecutor,
  ) async {
    await databaseExecutor.execute(
        'insert into $TABLE_PRODUCT('
        ' $TABLE_PRODUCT_COLUMN_BARCODE,'
        ' $_TABLE_PRODUCT_COLUMN_JSON,'
        ' ${LocalDatabase.COLUMN_TIMESTAMP}'
        ')values(?, ?, ?)'
        ' on conflict($TABLE_PRODUCT_COLUMN_BARCODE) DO UPDATE SET '
        '  $_TABLE_PRODUCT_COLUMN_JSON=excluded.$_TABLE_PRODUCT_COLUMN_JSON,'
        '  ${LocalDatabase.COLUMN_TIMESTAMP}=excluded.${LocalDatabase.COLUMN_TIMESTAMP}',
        <dynamic>[
          product.barcode,
          json.encode(product.toJson()),
          LocalDatabase.nowInMillis(),
        ]); // TODO(monsieurtanuki): check if this upsert does not cause delete+insert, but just update
  }

  Product _getProductFromQueryResult(final Map<String, dynamic> row) {
    final String encodedJson = row[_TABLE_PRODUCT_COLUMN_JSON] as String;
    final Map<String, dynamic> decodedJson =
        json.decode(encodedJson) as Map<String, dynamic>;
    return Product.fromJson(decodedJson);
  }
}
