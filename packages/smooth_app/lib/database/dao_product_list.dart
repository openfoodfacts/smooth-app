import 'dart:async';

import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_extra.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaoProductList extends AbstractDao {
  DaoProductList(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _TABLE_PRODUCT_LIST = 'product_list';
  static const String _TABLE_PRODUCT_LIST_COLUMN_ID = '_id';
  static const String _TABLE_PRODUCT_LIST_COLUMN_TYPE = 'list_type';
  static const String _TABLE_PRODUCT_LIST_COLUMN_PARAMETERS = 'parameters';

  static const String _TABLE_PRODUCT_LIST_EXTRA = 'product_list_extra';
  static const String _TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID = 'list_id';
  static const String _TABLE_PRODUCT_LIST_EXTRA_COLUMN_KEY = 'extra_key';
  static const String _TABLE_PRODUCT_LIST_EXTRA_COLUMN_VALUE = 'extra_value';

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    const String _TABLE_PRODUCT_LIST_ITEM = 'product_list_item';
    const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_ID = '_id';
    const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID = 'list_id';
    const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE = 'barcode';

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

      await db.execute(
          'create table $_TABLE_PRODUCT_LIST_ITEM(' // to be dropped
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
    if (oldVersion < 7) {
      // removing the FK of table product list item to table product
      const String TMP_TABLE_NAME = 'ngjkd';
      await db.execute('create table $TMP_TABLE_NAME('
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,'
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID INT NOT NULL,'
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE TEXT NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL,'
          'FOREIGN KEY ($_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID)'
          ' REFERENCES $_TABLE_PRODUCT_LIST'
          '  ($_TABLE_PRODUCT_LIST_COLUMN_ID)'
          '   ON DELETE CASCADE '
          ')');
      const String COLUMNS = '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_ID,'
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID,'
          '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE,'
          '${LocalDatabase.COLUMN_TIMESTAMP} ';
      await db.execute('insert into $TMP_TABLE_NAME($COLUMNS) '
          'select $COLUMNS from $_TABLE_PRODUCT_LIST_ITEM');
      await db.execute('drop table $_TABLE_PRODUCT_LIST_ITEM');
      await db.execute(
          'alter table $TMP_TABLE_NAME rename to $_TABLE_PRODUCT_LIST_ITEM');
    }
    if (oldVersion < 8) {
      // moving from product list item to product_extra
      // and dropping table product list item
      await db.transaction(
        (final Transaction transaction) async {
          await _upgradeToVersion8(transaction);
          await transaction.execute('drop table $_TABLE_PRODUCT_LIST_ITEM');
        },
      );
    }
  }

  Future<int?> getTimestamp(final ProductList productList) async {
    final Map<String, dynamic>? record = await _getRecord(
      productList,
      localDatabase.database,
    );
    if (record == null) {
      return null;
    }
    return record[LocalDatabase.COLUMN_TIMESTAMP] as int;
  }

  Future<int?> _getId(
    final ProductList productList,
    final DatabaseExecutor databaseExecutor,
  ) async {
    final Map<String, dynamic>? record = await _getRecord(
      productList,
      databaseExecutor,
    );
    if (record == null) {
      return null;
    }
    return record[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
  }

  static String _getProductListUKWhere() =>
      '$_TABLE_PRODUCT_LIST_COLUMN_TYPE = ?'
      ' AND $_TABLE_PRODUCT_LIST_COLUMN_PARAMETERS = ?';

  static List<String> _getProductListUKWhereArgs(
          final ProductList productList) =>
      <String>[productList.listType, productList.parameters];

  Future<Map<String, dynamic>?> _getRecord(
    final ProductList productList,
    final DatabaseExecutor databaseExecutor,
  ) async {
    if (productList.listType == ProductList.LIST_TYPE_HISTORY ||
        productList.listType == ProductList.LIST_TYPE_SCAN) {
      return null;
    }
    final List<Map<String, dynamic>> queryResult = await databaseExecutor.query(
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

  // TODO(monsieurtanuki): remove when this code is never called anymore
  static Future<void> _upgradeToVersion8(
      final DatabaseExecutor databaseExecutor) async {
    const String _TABLE_PRODUCT_LIST_ITEM = 'product_list_item';
    const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_ID = '_id';
    const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID = 'list_id';
    const String _TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE = 'barcode';

    // listing the product lists that are not concerned
    final Set<int> toBeIgnoredLists = <int>{};
    final List<Map<String, dynamic>> queryResultsPre =
        await databaseExecutor.query(
      _TABLE_PRODUCT_LIST,
      columns: <String>[_TABLE_PRODUCT_LIST_COLUMN_ID],
      where: '$_TABLE_PRODUCT_LIST_COLUMN_TYPE in (?, ?)',
      whereArgs: <String>[
        ProductList.LIST_TYPE_HISTORY,
        ProductList.LIST_TYPE_SCAN,
      ],
    );
    for (final Map<String, dynamic> row in queryResultsPre) {
      final int id = row[_TABLE_PRODUCT_LIST_COLUMN_ID] as int;
      toBeIgnoredLists.add(id);
    }

    final List<Map<String, dynamic>> queryResults =
        await databaseExecutor.query(
      _TABLE_PRODUCT_LIST_ITEM,
      columns: <String>[
        _TABLE_PRODUCT_LIST_ITEM_COLUMN_ID,
        _TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID,
        _TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE,
        LocalDatabase.COLUMN_TIMESTAMP,
      ],
      orderBy: '$_TABLE_PRODUCT_LIST_ITEM_COLUMN_ID DESC', // most recent wins
    );
    final Map<int, List<dynamic>> map = <int, List<dynamic>>{};
    for (final Map<String, dynamic> row in queryResults) {
      final int listId = row[_TABLE_PRODUCT_LIST_ITEM_COLUMN_LIST_ID] as int;
      if (toBeIgnoredLists.contains(listId)) {
        continue;
      }
      final String barcode =
          row[_TABLE_PRODUCT_LIST_ITEM_COLUMN_BARCODE] as String;
      final int timestamp = row[LocalDatabase.COLUMN_TIMESTAMP] as int;
      List<dynamic>? item = map[listId];
      if (item == null) {
        map[listId] = item = <dynamic>[];
      }
      item.add(barcode);
      item.add(timestamp);
    }
    for (final int listId in map.keys) {
      final String extraKey = 'list/$listId';
      const String STRING_PARAMETER = '';
      const List<String> COLUMN_NAMES = <String>[
        DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE,
        'extra_key',
        'extra_value',
        'extra_int_value',
        LocalDatabase.COLUMN_TIMESTAMP,
      ];
      final String variables = '?${',?' * (COLUMN_NAMES.length - 1)}';
      final int numCols = COLUMN_NAMES.length;

      await databaseExecutor.delete(
        'product_extra',
        where: 'extra_key = ?',
        whereArgs: <String>[extraKey],
      );

      final List<dynamic> insertParameters = <dynamic>[];
      final List<dynamic> parameters = map[listId]!;
      final int max = parameters.length ~/ 2;
      final Map<String, int> timestamps = <String, int>{};
      for (int i = 0; i < parameters.length; i += 2) {
        final int index = max - (i ~/ 2);
        final String barcode = parameters[i] as String;
        final int timestamp = parameters[i + 1] as int;
        final int? previous = timestamps[barcode];
        if (previous != null) {
          continue;
        }
        timestamps[barcode] = timestamp;
        insertParameters.addAll(<dynamic>[
          barcode,
          extraKey,
          STRING_PARAMETER,
          index,
          timestamp,
        ]);

        if (insertParameters.length > 500) {
          final int additionalRecordsNumber =
              -1 + insertParameters.length ~/ numCols;
          await databaseExecutor.rawInsert(
              'insert into product_extra(${COLUMN_NAMES.join(',')}) '
              'values($variables)${',($variables)' * additionalRecordsNumber}',
              insertParameters);
          insertParameters.clear();
        }
      }
      if (insertParameters.isNotEmpty) {
        final int additionalRecordsNumber =
            -1 + insertParameters.length ~/ numCols;
        await databaseExecutor.rawInsert(
            'insert into product_extra(${COLUMN_NAMES.join(',')}) '
            'values($variables)${',($variables)' * additionalRecordsNumber}',
            insertParameters);
        insertParameters.clear();
      }
    }
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

  Future<void> put(final ProductList productList) async =>
      localDatabase.database.transaction(
        (final Transaction transaction) async =>
            DaoProductExtra(localDatabase).bulkInsertExtra(
          databaseExecutor: transaction,
          productList: productList,
          productListId: await _getId(productList, transaction),
        ),
      );

  Future<int> create(final ProductList productList) async =>
      _upsertProductList(productList, localDatabase.database);

  Future<bool> get(final ProductList productList) async =>
      DaoProductExtra(localDatabase).getList(
        productList,
        await _getId(productList, localDatabase.database),
      );

  Future<List<Product>> getFirstProducts(
    final ProductList productList,
    final int limit,
  ) async {
    final List<String>? barcodes =
        await DaoProductExtra(localDatabase).getFirstBarcodes(
      productList,
      await _getId(productList, localDatabase.database),
      limit,
    );
    final List<Product> result = <Product>[];
    if (barcodes == null) {
      return result;
    }
    final Map<String, Product> products =
        await DaoProduct(localDatabase).getAll(barcodes);
    for (final String barcode in barcodes) {
      final Product? product = products[barcode];
      if (product != null) {
        result.add(product);
      }
    }
    return result;
  }

  Future<void> delete(final ProductList productList) async {
    await localDatabase.database.transaction(
      (final Transaction transaction) async {
        final int? id = await _getId(productList, transaction);
        if (id != null) {
          await transaction.delete(
            _TABLE_PRODUCT_LIST,
            where: _getProductListUKWhere(),
            whereArgs: _getProductListUKWhereArgs(productList),
          );
        }
        await DaoProductExtra(localDatabase).clearList(
          productList,
          id,
          transaction,
        );
      },
    );
  }

  Future<Map<int, Map<String, String>>> _getExtras({final int? listId}) async {
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
      result[productListId]![key] = value;
    }
    return result;
  }

  Future<List<ProductList>> getAll({
    final bool withStats = true,
    final List<String>? typeFilter,
    final bool reverse = true,
    final int? limit,
  }) async {
    final Map<String, int> counts = withStats
        ? await DaoProductExtra(localDatabase).getStats()
        : <String, int>{};

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
        databaseCountDistinct: counts[productListId] ?? 0,
      )..extraTags = extras[productListId];
      result.add(item);
    }
    return result;
  }

  /// Returns the database primary key id of the [ProductList] for user lists
  /// or null for predetermined lists like "history"
  Future<int> _upsertProductList(
    final ProductList productList,
    final DatabaseExecutor databaseExecutor,
  ) async {
    int? id = await _getId(productList, databaseExecutor);
    if (id == null) {
      id = await databaseExecutor.insert(
        _TABLE_PRODUCT_LIST,
        <String, dynamic>{
          _TABLE_PRODUCT_LIST_COLUMN_TYPE: productList.listType,
          _TABLE_PRODUCT_LIST_COLUMN_PARAMETERS: productList.parameters,
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } else {
      await databaseExecutor.update(
        _TABLE_PRODUCT_LIST,
        <String, dynamic>{
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
        where: '$_TABLE_PRODUCT_LIST_COLUMN_ID = ?',
        whereArgs: <dynamic>[id],
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    }
    _upsertProductListExtra(productList.extraTags, id, databaseExecutor);
    return id;
  }

  static Future<void> _upsertProductListExtra(
    final Map<String, String>? extraTags,
    final int productListId,
    final DatabaseExecutor databaseExecutor,
  ) async {
    await databaseExecutor.delete(
      _TABLE_PRODUCT_LIST_EXTRA,
      where: '$_TABLE_PRODUCT_LIST_EXTRA_COLUMN_LIST_ID = ?',
      whereArgs: <dynamic>[productListId],
    );
    if (extraTags == null || extraTags.isEmpty) {
      return;
    }
    for (final MapEntry<String, String> entry in extraTags.entries) {
      await databaseExecutor.insert(
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
}
