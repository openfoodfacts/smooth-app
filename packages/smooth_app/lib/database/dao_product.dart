import 'dart:async';
import 'dart:convert';

import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/bulk_deletable.dart';
import 'package:smooth_app/database/bulk_manager.dart';
import 'package:smooth_app/database/dao_product_extra.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaoProduct extends AbstractDao implements BulkDeletable {
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
          '$TABLE_PRODUCT_COLUMN_BARCODE TEXT PRIMARY KEY,'
          '$_TABLE_PRODUCT_COLUMN_JSON TEXT NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL'
          ')');
    }
  }

  // TODO(monsieurtanuki): probably not relevant anymore; use product extra instead?
  Future<int?> getLastUpdate(final String barcode) async {
    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.query(
      TABLE_PRODUCT,
      columns: <String>[LocalDatabase.COLUMN_TIMESTAMP],
      where: '$TABLE_PRODUCT_COLUMN_BARCODE = ?',
      whereArgs: <dynamic>[barcode],
    );
    if (queryResult.isEmpty) {
      // not found
      return null;
    }
    // there's only one record expected, as barcode is the PK
    return queryResult.first[LocalDatabase.COLUMN_TIMESTAMP] as int;
  }

  Future<Product?> get(final String barcode) async {
    final Map<String, Product> map = await getAll(<String>[barcode]);
    return map[barcode];
  }

  // TODO(monsieurtanuki): use the max variable threshold AbstractDao.SQLITE_MAX_VARIABLE_NUMBER
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
    return _getAll(queryResults);
  }

  Future<Map<String, Product>> getAllWithExtras(final String extraKey) async {
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.rawQuery(
      'select '
      '  a.$TABLE_PRODUCT_COLUMN_BARCODE '
      ', a.$_TABLE_PRODUCT_COLUMN_JSON '
      'from '
      '  $TABLE_PRODUCT a '
      'where '
      '  exists(${DaoProductExtra.getExistsSubQuery()})',
      DaoProductExtra.getExistsSubQueryArgs(extraKey),
    );
    return _getAll(queryResults);
  }

  Map<String, Product> _getAll(final List<Map<String, dynamic>> queryResults) {
    final Map<String, Product> result = <String, Product>{};
    if (queryResults.isEmpty) {
      return result;
    }
    for (final Map<String, dynamic> row in queryResults) {
      result[row[TABLE_PRODUCT_COLUMN_BARCODE] as String] =
          _getProductFromQueryResult(row);
    }
    return result;
  }

  /// Returns the products that match a string
  ///
  /// The search is actually ugly, but it's a start.
  // TODO(monsieurtanuki): check only the fields that are deemed relevant
  // TODO(monsieurtanuki): consider space-separated fields as distinct keywords
  Future<List<Product>> getSuggestions(
      final String pattern, final int minLength) async {
    final List<Product> result = <Product>[];
    if (pattern.trim().length < minLength) {
      return result;
    }
    late String whereClause;
    late List<String> whereArgs;
    late String orderBy;
    if (int.tryParse(pattern) != null) {
      whereClause = 'a.$TABLE_PRODUCT_COLUMN_BARCODE like ?';
      whereArgs = <String>['%$pattern%'];
      orderBy = 'a.$TABLE_PRODUCT_COLUMN_BARCODE asc';
    } else {
      whereClause = 'exists(${DaoProductExtra.getExistsLikeSubQuery()})';
      whereArgs = DaoProductExtra.getExistsLikeSubQueryArgs(pattern);
      orderBy = 'a.${LocalDatabase.COLUMN_TIMESTAMP} desc';
    }
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.rawQuery(
      'select'
      '  a.$TABLE_PRODUCT_COLUMN_BARCODE '
      ', a.$_TABLE_PRODUCT_COLUMN_JSON '
      'from '
      '  $TABLE_PRODUCT a '
      'where '
      '  $whereClause '
      'order by '
      '  $orderBy',
      whereArgs,
    );
    for (final Map<String, dynamic> row in queryResults) {
      result.add(_getProductFromQueryResult(row));
    }
    return result;
  }

  /// Upserts products in database
  Future<void> put(final List<Product> products) async =>
      localDatabase.database.transaction((final Transaction transaction) async {
        final int timestamp = LocalDatabase.nowInMillis();
        final DaoProductExtra daoProductExtra = DaoProductExtra(localDatabase);
        await _bulkUpsertLoop(transaction, products, timestamp);
        await daoProductExtra.bulkUpsertLoopSimplifiedText(
          transaction,
          products,
          timestamp,
        );
        await daoProductExtra.bulkUpsertLoopLast(
          transaction,
          products,
          timestamp,
          DaoProductExtra.EXTRA_ID_LAST_REFRESH,
        );
      });

  /// Upserts product data in bulk mode
  Future<void> _bulkUpsertLoop(
    final DatabaseExecutor databaseExecutor,
    final List<Product> products,
    final int timestamp,
  ) async {
    final BulkManager bulkManager = BulkManager();
    final List<dynamic> insertParameters = <dynamic>[];
    final List<dynamic> deleteParameters = <dynamic>[];
    for (final Product product in products) {
      deleteParameters.add(product.barcode);
      insertParameters.add(product.barcode);
      insertParameters.add(json.encode(product.toJson()));
      insertParameters.add(timestamp);
    }
    await bulkManager.delete(
      bulkDeletable: this,
      parameters: deleteParameters,
      databaseExecutor: databaseExecutor,
    );
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
        LocalDatabase.COLUMN_TIMESTAMP,
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
