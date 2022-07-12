import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/bulk_deletable.dart';
import 'package:smooth_app/database/bulk_manager.dart';
import 'package:smooth_app/database/dao_product_migration.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

// TODO(monsieurtanuki): remove when old enough (today is 2022-07-07)
@Deprecated('use [DaoProduct] instead')
class DaoUnzippedProduct extends AbstractSqlDao
    implements
        BulkDeletable,
        DaoProductMigrationSource,
        DaoProductMigrationDestination {
  @Deprecated('use [DaoProduct] instead')
  DaoUnzippedProduct(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _TABLE_PRODUCT = 'product';
  static const String _TABLE_PRODUCT_COLUMN_BARCODE = 'barcode';
  static const String _TABLE_PRODUCT_COLUMN_JSON = 'encoded_json';

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 1) {
      await db.execute('create table $_TABLE_PRODUCT('
          // cf. https://www.sqlite.org/lang_conflict.html
          '$_TABLE_PRODUCT_COLUMN_BARCODE TEXT PRIMARY KEY on conflict replace'
          ',$_TABLE_PRODUCT_COLUMN_JSON TEXT NOT NULL'
          ')');
    }
  }

  Future<Product?> get(final String barcode) async {
    final Map<String, Product> map = await getAll(<String>[barcode]);
    return map[barcode];
  }

  @override
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
        columns: <String>[
          _TABLE_PRODUCT_COLUMN_BARCODE,
          _TABLE_PRODUCT_COLUMN_JSON,
        ],
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
        _TABLE_PRODUCT_COLUMN_BARCODE,
        _TABLE_PRODUCT_COLUMN_JSON,
      ];

  @override
  String getDeleteWhere(final List<dynamic> deleteWhereArgs) =>
      '$_TABLE_PRODUCT_COLUMN_BARCODE in (?${',?' * (deleteWhereArgs.length - 1)})';

  @override
  String getTableName() => _TABLE_PRODUCT;

  Product _getProductFromQueryResult(final Map<String, dynamic> row) {
    final String encodedJson = row[_TABLE_PRODUCT_COLUMN_JSON] as String;
    final Map<String, dynamic> decodedJson =
        json.decode(encodedJson) as Map<String, dynamic>;
    return Product.fromJson(decodedJson);
  }

  @override
  Future<void> deleteAll(final List<String> barcodes) async {
    final BulkManager bulkManager = BulkManager();
    localDatabase.database.transaction(
      (final Transaction transaction) async => bulkManager.delete(
        bulkDeletable: this,
        parameters: barcodes,
        databaseExecutor: transaction,
      ),
    );
  }
}
