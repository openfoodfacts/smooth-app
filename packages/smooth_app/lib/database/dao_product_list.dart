import 'dart:async';
import 'package:smooth_app/database/dao_product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:openfoodfacts/model/Product.dart';

class DaoProductList {
  DaoProductList(this.localDatabase);

  final LocalDatabase localDatabase;

  static const String _TABLE_PRODUCT_LIST = 'product_list';
  static const String _TABLE_PRODUCT_LIST_COLUMN_ID = '_id';
  static const String _TABLE_PRODUCT_LIST_COLUMN_TYPE = 'list_type';
  static const String _TABLE_PRODUCT_LIST_COLUMN_PARAMETERS = 'parameters';

  static const String _TABLE_PRODUCT_LIST_ITEM = 'product_list_item';
  static const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_ID = '_id';
  static const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID = 'list_id';
  static const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE = 'barcode';

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('create table $_TABLE_PRODUCT_LIST('
          '$_TABLE_PRODUCT_LIST_COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,'
          '$_TABLE_PRODUCT_LIST_COLUMN_TYPE TEXT NOT NULL,'
          '$_TABLE_PRODUCT_LIST_COLUMN_PARAMETERS TEXT NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL'
          ')');

      await db.execute('CREATE UNIQUE INDEX ${_TABLE_PRODUCT_LIST}_UK '
          'ON $_TABLE_PRODUCT_LIST('
          '$_TABLE_PRODUCT_LIST_COLUMN_TYPE,'
          '$_TABLE_PRODUCT_LIST_COLUMN_PARAMETERS'
          ')');

      await db.execute('create table $_TABLE_PRODUCT_LIST_ITEM('
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,'
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID INT NOT NULL,'
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE TEXT NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL,'
          'FOREIGN KEY ($_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID)'
          ' REFERENCES $_TABLE_PRODUCT_LIST'
          '  ($_TABLE_PRODUCT_LIST_COLUMN_ID)'
          '   ON DELETE CASCADE,'
          'FOREIGN KEY ($_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE)'
          ' REFERENCES ${DaoProduct.TABLE_PRODUCT}'
          '  (${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE})'
          '   ON DELETE CASCADE'
          ')');
    }
  }

  Future<int> getTimestamp(final ProductList productList) async {
    final Map<String, dynamic> record = await _getRecord(productList);
    if (record == null) {
      return null;
    }
    return record[LocalDatabase.COLUMN_TIMESTAMP] as int;
  }

  Future<Map<String, dynamic>> _getRecord(final ProductList productList) async {
    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.query(
      _TABLE_PRODUCT_LIST,
      columns: <String>[
        _TABLE_PRODUCT_LIST_COLUMN_ID,
        LocalDatabase.COLUMN_TIMESTAMP,
      ],
      where: '$_TABLE_PRODUCT_LIST_COLUMN_TYPE = ?'
          ' AND $_TABLE_PRODUCT_LIST_COLUMN_PARAMETERS = ?',
      whereArgs: <String>[productList.listType, productList.parameters],
    );
    if (queryResult.isEmpty) {
      // not found
      return null;
    }
    if (queryResult.length > 1) {
      // very very unlikely to happen
      throw Exception('Several product lists with the same PK');
    }
    return queryResult.first;
  }

  Future<void> put(final ProductList productList) async {
    final int productListId = await _upsertProductList(productList);
    await DaoProduct(localDatabase).putProducts(productList.getList());
    await _refreshListItems(productList, productListId);
  }

  Future<bool> get(final ProductList productList) async {
    final Map<String, dynamic> record = await _getRecord(productList);
    if (record == null) {
      return false;
    }
    final int id = record[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
    final List<String> barcodes = await _getBarcodes(id);
    final Map<String, Product> products =
        await DaoProduct(localDatabase).getAll(barcodes);
    productList.set(barcodes, products);
    return true;
  }

  Future<List<String>> _getBarcodes(final int id) async {
    const String BARCODE_COLUMN_NAME = _TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE;
    final List<Map<String, dynamic>> query = await localDatabase.database.query(
        _TABLE_PRODUCT_LIST_ITEM,
        where: '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID = ?',
        whereArgs: <dynamic>[id],
        columns: <String>[BARCODE_COLUMN_NAME],
        orderBy: '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_ID ASC');
    final List<String> result = <String>[];
    for (final Map<String, dynamic> row in query) {
      result.add(row[BARCODE_COLUMN_NAME] as String);
    }
    return result;
  }

  Future<int> _upsertProductList(final ProductList productList) async {
    final Map<String, dynamic> record = await _getRecord(productList);
    int id;
    if (record == null) {
      id = await localDatabase.database.insert(
        _TABLE_PRODUCT_LIST,
        <String, dynamic>{
          _TABLE_PRODUCT_LIST_COLUMN_TYPE: productList.listType,
          _TABLE_PRODUCT_LIST_COLUMN_PARAMETERS: productList.parameters,
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } else {
      id = record[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
      await localDatabase.database.update(
        _TABLE_PRODUCT_LIST,
        <String, dynamic>{
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
        where: '$_TABLE_PRODUCT_LIST_COLUMN_ID = ?',
        whereArgs: <dynamic>[id],
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    }
    return id;
  }

  Future<void> _refreshListItems(
      final ProductList productList, final int id) async {
    await _deleteListItems(id);
    await _insertListItems(id, productList.barcodes);
  }

  Future<void> _deleteListItems(final int id) async =>
      await localDatabase.database.delete(
        _TABLE_PRODUCT_LIST_ITEM,
        where: '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID = ?',
        whereArgs: <dynamic>[id],
      );

  Future<void> _insertListItems(
      final int id, final List<String> barcodes) async {
    for (final String barcode in barcodes) {
      // TODO(monsieurtanuki): optim
      await localDatabase.database.insert(
        _TABLE_PRODUCT_LIST_ITEM,
        <String, dynamic>{
          _TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE: barcode,
          _TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID: id,
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
    }
  }
}
