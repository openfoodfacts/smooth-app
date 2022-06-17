import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/bulk_deletable.dart';
import 'package:smooth_app/database/bulk_manager.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaoProduct extends AbstractSqlDao implements BulkDeletable {
  DaoProduct(final LocalDatabase localDatabase) : super(localDatabase);

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
          // cf. https://www.sqlite.org/lang_conflict.html
          '$TABLE_PRODUCT_COLUMN_BARCODE TEXT PRIMARY KEY on conflict replace'
          ',$_TABLE_PRODUCT_COLUMN_JSON TEXT NOT NULL'
          ')');
    }
  }

  Future<Product?> get(final String barcode) async {
    final Map<String, Product> map = await getAll(<String>[barcode]);
    return map[barcode];
  }

  // TODO(monsieurtanuki): use the max variable threshold BulkManager.SQLITE_MAX_VARIABLE_NUMBER
  Future<Map<String, Product>> getAll(final List<String> barcodes) async {
    final Map<String, Product> result = <String, Product>{};
    if (barcodes.isEmpty) {
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

  Future<int> clearAll() async {
    final int count = await localDatabase.database.delete(TABLE_PRODUCT);
    return count;
  }

  Future<double> getSize() async {
    final String path = localDatabase.database.path;
    final File file = File(path);
    final double size = file.lengthSync() / 1024 / 1024;
    return double.parse(
      size.floor().toStringAsFixed(
            2,
          ),
    );
  }

  Future<int?> getLength() async {
    return Sqflite.firstIntValue(await localDatabase.database
        .rawQuery('SELECT COUNT(*) FROM $TABLE_PRODUCT'));
  }

  Future<void> put(final Product product) async => putAll(<Product>[product]);

  /// Replaces products in database
  Future<void> putAll(final Iterable<Product> products) async =>
      localDatabase.database.transaction(
        (final Transaction transaction) async =>
            _bulkReplaceLoop(transaction, products),
      );

  Future<List<String>> getAllKeys() async {
    final List<String> result = <String>[];
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      TABLE_PRODUCT,
      columns: <String>[
        TABLE_PRODUCT_COLUMN_BARCODE,
      ],
    );
    if (queryResults.isEmpty) {
      return result;
    }
    for (final Map<String, dynamic> row in queryResults) {
      result.add(row[TABLE_PRODUCT_COLUMN_BARCODE] as String);
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
    final BulkManager bulkManager = BulkManager();
    final List<dynamic> insertParameters = <dynamic>[];
    for (final Product product in products) {
      insertParameters.add(product.barcode);
      insertParameters.add(json.encode(product.toJson()));
    }
    await bulkManager.insert(
      bulkInsertable: this,
      parameters: insertParameters,
      databaseExecutor: databaseExecutor,
    );
  }

  @override
  List<String> getInsertColumns() => <String>[
        TABLE_PRODUCT_COLUMN_BARCODE,
        _TABLE_PRODUCT_COLUMN_JSON,
      ];

  @override
  String getDeleteWhere(final List<dynamic> deleteWhereArgs) =>
      '$TABLE_PRODUCT_COLUMN_BARCODE in (?${',?' * (deleteWhereArgs.length - 1)})';

  @override
  String getTableName() => TABLE_PRODUCT;

  Product _getProductFromQueryResult(final Map<String, dynamic> row) {
    final String encodedJson = row[_TABLE_PRODUCT_COLUMN_JSON] as String;
    final Map<String, dynamic> decodedJson =
        json.decode(encodedJson) as Map<String, dynamic>;
    return Product.fromJson(decodedJson);
  }
}
