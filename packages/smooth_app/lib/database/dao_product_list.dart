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

  static const String _TABLE_PRODUCT_LIST_EXTRA = 'product_list_extra';
  static const String _TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID = 'list_id';
  static const String _TABLE_PRODUCT_LIST_EXTRA_COLUMN_KEY = 'extra_key';
  static const String _TABLE_PRODUCT_LIST_EXTRA_COLUMN_VALUE = 'extra_value';

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
    if (oldVersion < 3) {
      await db.execute('create table $_TABLE_PRODUCT_LIST_EXTRA('
          '$_TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID INT NOT NULL,'
          '$_TABLE_PRODUCT_LIST_EXTRA_COLUMN_KEY TEXT NOT NULL,'
          '$_TABLE_PRODUCT_LIST_EXTRA_COLUMN_VALUE TEXT NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL,'
          'PRIMARY KEY ('
          '$_TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID,'
          '$_TABLE_PRODUCT_LIST_EXTRA_COLUMN_KEY),'
          'FOREIGN KEY ($_TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID)'
          ' REFERENCES $_TABLE_PRODUCT_LIST'
          '  ($_TABLE_PRODUCT_LIST_COLUMN_ID)'
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

  static String _getProductListUKWhere() =>
      '$_TABLE_PRODUCT_LIST_COLUMN_TYPE = ?'
      ' AND $_TABLE_PRODUCT_LIST_COLUMN_PARAMETERS = ?';

  static List<String> _getProductListUKWhereArgs(
          final ProductList productList) =>
      <String>[productList.listType, productList.parameters];

  Future<Map<String, dynamic>> _getRecord(final ProductList productList) async {
    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.query(
      _TABLE_PRODUCT_LIST,
      columns: <String>[
        _TABLE_PRODUCT_LIST_COLUMN_ID,
        LocalDatabase.COLUMN_TIMESTAMP,
      ],
      where: _getProductListUKWhere(),
      whereArgs: _getProductListUKWhereArgs(productList),
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

  Future<bool> rename(
    final ProductList productList,
    final String newName,
  ) async {
    try {
      final int nbUpdated = await localDatabase.database.update(
        _TABLE_PRODUCT_LIST,
        <String, dynamic>{
          _TABLE_PRODUCT_LIST_COLUMN_PARAMETERS: newName,
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
        where: _getProductListUKWhere(),
        whereArgs: _getProductListUKWhereArgs(productList),
      );
      return nbUpdated == 1;
    } catch (e) {
      return false;
    }
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

  Future<List<String>> getFirstBarcodes(
    final ProductList productList,
    final int limit,
    final bool reverse,
    final bool unique,
  ) async {
    final Map<String, dynamic> record = await _getRecord(productList);
    if (record == null) {
      return null;
    }
    final int id = record[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
    return await _getBarcodes(
      id,
      limit: limit,
      reverse: reverse,
      unique: unique,
    );
  }

  Future<List<Product>> getFirstProducts(
    final ProductList productList,
    final int limit,
    final bool reverse,
    final bool unique,
  ) async {
    final List<String> barcodes = await getFirstBarcodes(
      productList,
      limit,
      reverse,
      unique,
    );
    final Map<String, Product> products =
        await DaoProduct(localDatabase).getAll(barcodes);
    final List<Product> result = <Product>[];
    for (final String barcode in barcodes) {
      final Product product = products[barcode];
      if (product != null) {
        result.add(product);
      }
    }
    return result;
  }

  Future<int> removeBarcode(
    final ProductList productList,
    final String barcode,
  ) async =>
      _addOrRemoveBarcode(productList, barcode, false);

  Future<int> addBarcode(
    final ProductList productList,
    final String barcode,
  ) async =>
      _addOrRemoveBarcode(productList, barcode, true);

  Future<int> _addOrRemoveBarcode(
    final ProductList productList,
    final String barcode,
    final bool addOrRemove,
  ) async {
    final int id = await _upsertProductList(productList);
    if (addOrRemove) {
      productList.barcodes.add(barcode);
      await _insertListItem(id, barcode);
      return 1;
    }
    productList.barcodes.removeWhere((String element) => element == barcode);
    return await localDatabase.database.delete(
      _TABLE_PRODUCT_LIST_ITEM,
      where: '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID = ? '
          'and $_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE = ?',
      whereArgs: <dynamic>[id, barcode],
    );
  }

  Future<int> delete(final ProductList productList) async =>
      await localDatabase.database.delete(
        _TABLE_PRODUCT_LIST,
        where: _getProductListUKWhere(),
        whereArgs: _getProductListUKWhereArgs(productList),
      );

  Future<int> clear(final ProductList productList) async {
    final Map<String, dynamic> record = await _getRecord(productList);
    if (record == null) {
      return null;
    }
    productList.barcodes.clear();
    final int id = record[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
    return _clearListItems(id);
  }

  Future<int> paste(
    final ProductList destination,
    final String sourceLousyKey,
  ) async {
    final int sourceId = await _getProductListIdFromLousyKey(sourceLousyKey);
    if (sourceId == null) {
      return null;
    }
    final List<String> barcodes = await _getBarcodes(sourceId);
    _upsertProductList(destination);
    final Map<String, dynamic> record = await _getRecord(destination);
    if (record == null) {
      // not very likely
      return null;
    }
    final int destinationId = record[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
    final int result = await _insertListItems(destinationId, barcodes);
    await get(destination);
    return result;
  }

  Future<int> _getProductListIdFromLousyKey(final String lousyKey) async {
    // TODO(monsieurtanuki): optim
    final List<ProductList> all = await getAll(withStats: false);
    for (final ProductList productList in all) {
      if (productList.lousyKey == lousyKey) {
        final Map<String, dynamic> record = await _getRecord(productList);
        if (record == null) {
          // very unlikely
          return null;
        }
        return record[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
      }
    }
    return null;
  }

  Future<Map<int, Map<String, String>>> _getExtras({final int listId}) async {
    final Map<int, Map<String, String>> result = <int, Map<String, String>>{};
    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.query(
      _TABLE_PRODUCT_LIST_EXTRA,
      columns: <String>[
        _TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID,
        _TABLE_PRODUCT_LIST_EXTRA_COLUMN_KEY,
        _TABLE_PRODUCT_LIST_EXTRA_COLUMN_VALUE,
      ],
      where: listId == null
          ? null
          : '$_TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID = ?',
      whereArgs: listId == null ? null : <dynamic>[listId],
    );
    for (final Map<String, dynamic> row in queryResult) {
      final int productListId =
          row[_TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID] as int;
      final String key = row[_TABLE_PRODUCT_LIST_EXTRA_COLUMN_KEY] as String;
      final String value =
          row[_TABLE_PRODUCT_LIST_EXTRA_COLUMN_VALUE] as String;
      if (result[productListId] == null) {
        result[productListId] = <String, String>{};
      }
      result[productListId][key] = value;
    }
    return result;
  }

  Future<List<ProductList>> getAll({
    final bool withStats = true,
    final List<String> typeFilter,
    final bool reverse = true,
    final int limit,
  }) async {
    final Map<int, int> counts = <int, int>{};
    final Map<int, int> countDistincts = <int, int>{};

    if (withStats) {
      const String COLUMN_NAME_COUNT = 'my_count';
      const String COLUMN_NAME_COUNT_DISTINCT = 'my_count_distinct';
      final List<Map<String, dynamic>> countResult =
          await localDatabase.database.rawQuery(
        'select '
        '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID,'
        'count($_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE) as $COLUMN_NAME_COUNT,'
        'count(distinct $_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE) as $COLUMN_NAME_COUNT_DISTINCT '
        'from $_TABLE_PRODUCT_LIST_ITEM '
        'group by $_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID',
      );
      for (final Map<String, dynamic> row in countResult) {
        final int productListId =
            row[_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID] as int;
        counts[productListId] = row[COLUMN_NAME_COUNT] as int;
        countDistincts[productListId] = row[COLUMN_NAME_COUNT_DISTINCT] as int;
      }
    }

    final Map<int, Map<String, String>> extras = await _getExtras();
    final List<ProductList> result = <ProductList>[];
    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.query(
      _TABLE_PRODUCT_LIST,
      columns: <String>[
        _TABLE_PRODUCT_LIST_COLUMN_ID,
        LocalDatabase.COLUMN_TIMESTAMP,
        _TABLE_PRODUCT_LIST_COLUMN_TYPE,
        _TABLE_PRODUCT_LIST_COLUMN_PARAMETERS
      ],
      where: typeFilter == null || typeFilter.isEmpty
          ? null
          : '$_TABLE_PRODUCT_LIST_COLUMN_TYPE in (?${(', ?') * (typeFilter.length - 1)})',
      whereArgs: typeFilter == null || typeFilter.isEmpty ? null : typeFilter,
      limit: limit,
      orderBy: '${LocalDatabase.COLUMN_TIMESTAMP} ${reverse ? 'DESC' : 'ASC'}',
    );
    for (final Map<String, dynamic> row in queryResult) {
      final int productListId = row[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
      final ProductList item = ProductList(
        listType: row[_TABLE_PRODUCT_LIST_COLUMN_TYPE] as String,
        parameters: row[_TABLE_PRODUCT_LIST_COLUMN_PARAMETERS] as String,
        databaseTimestamp: row[LocalDatabase.COLUMN_TIMESTAMP] as int,
        databaseCount: counts[productListId],
        databaseCountDistinct: countDistincts[productListId],
      )..extraTags = extras[productListId];
      result.add(item);
    }
    return result;
  }

  Future<List<ProductList>> getAllWithBarcode(final String barcode) async {
    final List<ProductList> result = <ProductList>[];
    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.rawQuery(
      'select '
      '$_TABLE_PRODUCT_LIST_COLUMN_TYPE,'
      '$_TABLE_PRODUCT_LIST_COLUMN_PARAMETERS '
      'from $_TABLE_PRODUCT_LIST L '
      'where '
      'exists('
      'select null from $_TABLE_PRODUCT_LIST_ITEM I '
      'where L.$_TABLE_PRODUCT_LIST_COLUMN_ID = I.$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID '
      'and I.$_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE = ?)',
      <String>[barcode],
    );
    for (final Map<String, dynamic> row in queryResult) {
      final ProductList item = ProductList(
        listType: row[_TABLE_PRODUCT_LIST_COLUMN_TYPE] as String,
        parameters: row[_TABLE_PRODUCT_LIST_COLUMN_PARAMETERS] as String,
      );
      result.add(item);
    }
    return result;
  }

  Future<List<String>> _getBarcodes(
    final int id, {
    final int limit,
    final bool reverse = false,
    final bool unique = false,
  }) async {
    const String BARCODE_COLUMN_NAME = _TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE;
    final List<Map<String, dynamic>> query = await localDatabase.database.query(
      _TABLE_PRODUCT_LIST_ITEM,
      where: '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID = ?',
      whereArgs: <dynamic>[id],
      columns: <String>[BARCODE_COLUMN_NAME],
      orderBy:
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_ID ${reverse ? 'DESC' : 'ASC'}',
      limit: unique ? null : limit,
    );
    final List<String> result = <String>[];
    for (final Map<String, dynamic> row in query) {
      final String barcode = row[BARCODE_COLUMN_NAME] as String;
      if ((!unique) || !result.contains(barcode)) {
        result.add(barcode);
        if (limit != null && result.length >= limit) {
          break;
        }
      }
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
    _upsertProductListExtra(productList.extraTags, id);
    return id;
  }

  Future<void> _upsertProductListExtra(
    final Map<String, String> extraTags,
    final int productListId,
  ) async {
    await localDatabase.database.delete(
      _TABLE_PRODUCT_LIST_EXTRA,
      where: '$_TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID = ?',
      whereArgs: <dynamic>[productListId],
    );
    if (extraTags == null) {
      return;
    }
    for (final MapEntry<String, String> entry in extraTags.entries) {
      await localDatabase.database.insert(
        _TABLE_PRODUCT_LIST_EXTRA,
        <String, dynamic>{
          _TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID: productListId,
          _TABLE_PRODUCT_LIST_EXTRA_COLUMN_KEY: entry.key,
          _TABLE_PRODUCT_LIST_EXTRA_COLUMN_VALUE: entry.value,
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
      );
    }
  }

  Future<void> _refreshListItems(
      final ProductList productList, final int id) async {
    await _clearListItems(id);
    await _insertListItems(id, productList.barcodes);
  }

  Future<int> _clearListItems(final int id) async =>
      await localDatabase.database.delete(
        _TABLE_PRODUCT_LIST_ITEM,
        where: '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID = ?',
        whereArgs: <dynamic>[id],
      );

  Future<int> _insertListItems(
      final int id, final List<String> barcodes) async {
    for (final String barcode in barcodes) {
      await _insertListItem(id, barcode);
      // TODO(monsieurtanuki): optim
    }
    return barcodes.length;
  }

  Future<void> _insertListItem(final int id, final String barcode) async =>
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
