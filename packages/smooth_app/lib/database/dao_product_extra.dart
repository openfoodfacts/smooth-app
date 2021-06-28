import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/data_models/product_extra.dart';
import 'package:diacritic/diacritic.dart';
import 'package:smooth_app/data_models/product_list.dart';

/// DAO for Product Extra data
///
/// For a key and a barcode, we store a string value and an integer value.
/// The whole idea is to store:
/// - interesting data in the string value, e.g. in json,
/// - and an integer value accessible in a SQL "order by" clause
/// A typical use case is for timestamps history (e.g. scan, view or refresh).
/// In that case the integer value contains the latest timestamp,
/// and the string value contains a list of timestamps encoded as json.
class DaoProductExtra extends AbstractDao {
  DaoProductExtra(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _TABLE_PRODUCT_EXTRA = 'product_extra';
  static const String _TABLE_PRODUCT_EXTRA_COLUMN_KEY = 'extra_key';
  static const String _TABLE_PRODUCT_EXTRA_COLUMN_VALUE = 'extra_value';
  static const String _TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE = 'extra_int_value';

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 4) {
      await db.execute('create table $_TABLE_PRODUCT_EXTRA('
          '${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE} TEXT NOT NULL,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY TEXT NOT NULL,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_VALUE TEXT NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL,'
          'PRIMARY KEY ('
          '${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE},'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY),'
          'FOREIGN KEY (${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE})' // FK dropped later
          ' REFERENCES ${DaoProduct.TABLE_PRODUCT}'
          '  (${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE})'
          '   ON DELETE CASCADE'
          ')');
    }
    if (oldVersion < 6) {
      await db.execute('alter table $_TABLE_PRODUCT_EXTRA '
          'ADD COLUMN $_TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE INT DEFAULT 0 NOT NULL');
    }
    if (oldVersion < 7) {
      // dropping the FK of table product extra to table product
      const String TMP_TABLE_NAME = 'ngjkdkjfesk';
      await db.execute('create table $TMP_TABLE_NAME('
          '${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE} TEXT NOT NULL,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY TEXT NOT NULL,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_VALUE TEXT NOT NULL,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE INT DEFAULT 0 NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL,'
          'PRIMARY KEY ('
          '${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE},'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY)'
          ')');
      const String COLUMNS = '${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE},'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_VALUE,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE,'
          '${LocalDatabase.COLUMN_TIMESTAMP} ';
      await db.execute(
        'insert into $TMP_TABLE_NAME($COLUMNS) '
        'select $COLUMNS from $_TABLE_PRODUCT_EXTRA',
      );
      await db.execute('drop table $_TABLE_PRODUCT_EXTRA');
      await db.execute(
          'alter table $TMP_TABLE_NAME rename to $_TABLE_PRODUCT_EXTRA');
    }
  }

  /// Returns the sub-query for products that have a product extra
  static String getExistsSubQuery() => ''
      'select '
      '  null '
      'from '
      '  $_TABLE_PRODUCT_EXTRA b '
      'where '
      '  a.${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE} = b.${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE} '
      '  and b.$_TABLE_PRODUCT_EXTRA_COLUMN_KEY = ? ';

  /// Returns the sub-query parameters for products that have a product extra
  static List<String> getExistsSubQueryArgs(final String key) => <String>[key];

  /// Returns the sub-query for products about the suggestion field
  static String getExistsLikeSubQuery() =>
      getExistsSubQuery() +
      '  and b.$_TABLE_PRODUCT_EXTRA_COLUMN_VALUE like ? ';

  /// Returns the sub-query parameters for products about the suggestion field
  static List<String> getExistsLikeSubQueryArgs(final String pattern) =>
      <String>[_EXTRA_ID_SIMPLIFIED_TEXT, '%${_getSimplifiedText(pattern)}%'];

  /// Adds a "last time I saw this product" timestamp entry
  Future<void> putLastSeen(final Product product) async =>
      await _putLast(product, EXTRA_ID_LAST_SEEN);

  /// Adds a "last time I scanned this product" timestamp entry
  Future<void> putLastScan(final Product product) async =>
      await _putLast(product, EXTRA_ID_LAST_SCAN);

  /// Adds a "last time I did whatever with this product" timestamp entry
  Future<void> _putLast(
    final Product product,
    final String extraKey, {
    int? timestamp,
    DatabaseExecutor? databaseExecutor,
  }) async =>
      await bulkUpsertLoopLast(
        databaseExecutor ?? localDatabase.database,
        <Product>[product],
        timestamp ?? LocalDatabase.nowInMillis(),
        extraKey,
      );

  /// Upserts the simplified text in bulk mode
  Future<void> bulkUpsertLoopSimplifiedText(
    final DatabaseExecutor databaseExecutor,
    final List<Product> products,
    final int timestamp,
  ) async {
    const String KEY = _EXTRA_ID_SIMPLIFIED_TEXT;
    final int maxRecordNumber = getBulkMaxRecordNumber();
    final List<dynamic> insertParameters = <dynamic>[];
    final List<String> deleteParameters = <String>[KEY];

    int counter = 0;
    for (final Product product in products) {
      deleteParameters.add(product.barcode!);
      insertParameters.add(product.barcode!);
      insertParameters.add(KEY);
      insertParameters.add(_getSimplifiedTextForProduct(product));
      insertParameters.add(0);
      insertParameters.add(timestamp);
      counter++;
      if (counter == maxRecordNumber) {
        await _bulkUpsert(insertParameters, deleteParameters, databaseExecutor);
        counter = 0;
        deleteParameters.clear();
        deleteParameters.add(KEY);
        insertParameters.clear();
      }
    }
    await _bulkUpsert(insertParameters, deleteParameters, databaseExecutor);
  }

  /// Upserts the "last time I did whatever with this product" in bulk mode
  Future<void> bulkUpsertLoopLast(
    final DatabaseExecutor databaseExecutor,
    final List<Product> products,
    final int timestamp,
    final String extraKey,
  ) async {
    final int maxRecordNumber = getBulkMaxRecordNumber();
    final List<dynamic> insertParameters = <dynamic>[];
    final List<String> deleteParameters = <String>[extraKey];

    final List<String> barcodes = <String>[];
    for (final Product product in products) {
      barcodes.add(product.barcode!);
    }
    final Map<String, ProductExtra> map = await getProductExtras(
      key: extraKey,
      barcodes: barcodes,
      databaseExecutor: databaseExecutor,
    );

    int counter = 0;
    for (final Product product in products) {
      final ProductExtra? productExtra = map[product.barcode];
      List<int> timestamps;
      if (productExtra == null) {
        timestamps = <int>[];
      } else {
        timestamps = productExtra.decodeStringAsIntList();
      }
      timestamps.add(timestamp);

      deleteParameters.add(product.barcode!);
      insertParameters.add(product.barcode!);
      insertParameters.add(extraKey);
      insertParameters.add(jsonEncode(timestamps)); // string value
      insertParameters.add(timestamp); // int value
      insertParameters.add(timestamp);
      counter++;
      if (counter == maxRecordNumber) {
        await _bulkUpsert(insertParameters, deleteParameters, databaseExecutor);
        counter = 0;
        deleteParameters.clear();
        deleteParameters.add(extraKey);
        insertParameters.clear();
      }
    }
    await _bulkUpsert(insertParameters, deleteParameters, databaseExecutor);
  }

  @override
  List<String> getBulkInsertColumns() => <String>[
        DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE,
        _TABLE_PRODUCT_EXTRA_COLUMN_KEY,
        _TABLE_PRODUCT_EXTRA_COLUMN_VALUE,
        _TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE,
        LocalDatabase.COLUMN_TIMESTAMP,
      ];

  @override
  String getTableName() => _TABLE_PRODUCT_EXTRA;

  /// Bulk upsert of product extra
  Future<void> _bulkUpsert(
    final List<dynamic> insertParameters,
    final List<String> deleteParameters,
    final DatabaseExecutor databaseExecutor,
  ) async =>
      await bulkUpsert(
        insertParameters: insertParameters,
        deleteParameters: deleteParameters,
        deleteWhere: '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY = ? '
            'and ${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE} in (?${',?' * (deleteParameters.length - 2)})',
        databaseExecutor: databaseExecutor,
      );

  /// Returns a lowercase not accented version of the text, for comparisons
  static String _getSimplifiedText(final String? text) {
    if (text == null) {
      return '';
    }
    return removeDiacritics(text).toLowerCase();
  }

  /// Extra id for a simplified version of the text, for search purposes
  static const String _EXTRA_ID_SIMPLIFIED_TEXT = 'simplified_text';

  /// Extra id for each time the user went to the product page
  static const String EXTRA_ID_LAST_SEEN = 'last_seen';

  /// Extra id for each time the user scanned a product
  static const String EXTRA_ID_LAST_SCAN = 'last_scan';

  /// Extra id for each time the product data was refreshed from the web
  static const String EXTRA_ID_LAST_REFRESH = 'last_refresh';

  static String _getSimplifiedTextForProduct(final Product product) {
    final List<String> labels = <String>[];
    if (product.productName != null) {
      labels.add(_getSimplifiedText(product.productName));
    }
    if (product.productNameFR != null) {
      labels.add(_getSimplifiedText(product.productNameFR));
    }
    if (product.productNameDE != null) {
      labels.add(_getSimplifiedText(product.productNameDE));
    }
    if (product.productNameEN != null) {
      labels.add(_getSimplifiedText(product.productNameEN));
    }
    return labels.isEmpty ? '' : labels.join(', ');
  }

  /// Returns the ordered [ProductExtra]s for all products with an extra [key]
  Future<LinkedHashMap<String, ProductExtra>> getOrderedProductExtras({
    required final String key,
    required final bool reverse,
    final int? limit,
  }) async {
    final LinkedHashMap<String, ProductExtra> result =
        LinkedHashMap<String, ProductExtra>();
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      _TABLE_PRODUCT_EXTRA,
      columns: <String>[
        DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE,
        _TABLE_PRODUCT_EXTRA_COLUMN_VALUE,
        _TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE,
      ],
      where: '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY = ?',
      whereArgs: <String>[key],
      orderBy:
          '$_TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE ${reverse ? 'DESC' : 'ASC'}',
      limit: limit,
    );
    for (final Map<String, dynamic> row in queryResults) {
      final String barcode =
          row[DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE] as String;
      final String stringValue =
          row[_TABLE_PRODUCT_EXTRA_COLUMN_VALUE] as String;
      final int intValue = row[_TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE] as int;
      result[barcode] = ProductExtra(intValue, stringValue);
    }
    return result;
  }

  /// Returns the [ProductExtra] values for an extra [key] and several [barcode]s
  Future<Map<String, ProductExtra>> getProductExtras({
    required final String key,
    required final Iterable<String> barcodes,
    DatabaseExecutor? databaseExecutor,
  }) async {
    final Map<String, ProductExtra> result = <String, ProductExtra>{};
    if (barcodes.isEmpty) {
      return result;
    }
    databaseExecutor ??= localDatabase.database;
    final List<String> whereArgs = <String>[key];
    whereArgs.addAll(barcodes);
    final List<Map<String, dynamic>> queryResults =
        await databaseExecutor.query(
      _TABLE_PRODUCT_EXTRA,
      columns: <String>[
        DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE,
        _TABLE_PRODUCT_EXTRA_COLUMN_VALUE,
        _TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE,
      ],
      where: '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY = ? '
          'AND ${DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE} in (?${',?' * (barcodes.length - 1)})',
      whereArgs: whereArgs,
    );
    for (final Map<String, dynamic> row in queryResults) {
      final String barcode =
          row[DaoProduct.TABLE_PRODUCT_COLUMN_BARCODE] as String;
      final String stringValue =
          row[_TABLE_PRODUCT_EXTRA_COLUMN_VALUE] as String;
      final int intValue = row[_TABLE_PRODUCT_EXTRA_COLUMN_INT_VALUE] as int;
      result[barcode] = ProductExtra(intValue, stringValue);
    }
    return result;
  }

  /// Returns the [ProductExtra] for an extra [key] and a [barcode]
  Future<ProductExtra?> getProductExtra({
    required final String key,
    required final String barcode,
  }) async {
    final Map<String, ProductExtra> map = await getProductExtras(
      key: key,
      barcodes: <String>[barcode],
    );
    return map[barcode];
  }

  String? _getExtraKey(final ProductList productList) {
    switch (productList.listType) {
      case ProductList.LIST_TYPE_HISTORY:
        return EXTRA_ID_LAST_SEEN;
      case ProductList.LIST_TYPE_SCAN:
        return EXTRA_ID_LAST_SCAN;
    }
    return null;
  }

  bool? _getExtraReverse(final ProductList productList) {
    switch (productList.listType) {
      case ProductList.LIST_TYPE_HISTORY:
        return true;
      case ProductList.LIST_TYPE_SCAN:
        return false;
    }
    return null;
  }

  Future<bool> getList(final ProductList productList) async {
    final String? extraKey = _getExtraKey(productList);
    final bool? extraReverse = _getExtraReverse(productList);
    if (extraKey == null || extraReverse == null) {
      return false;
    }
    final LinkedHashMap<String, ProductExtra> extras =
        await getOrderedProductExtras(key: extraKey, reverse: extraReverse);
    final List<String> barcodes = List<String>.from(extras.keys);
    final Map<String, Product> products =
        await DaoProduct(localDatabase).getAllWithExtras(extraKey);
    productList.set(barcodes, products, productExtras: extras);
    return true;
  }

  Future<List<String>?> getFirstBarcodes(
    final ProductList productList,
    final int limit,
  ) async {
    final String? extraKey = _getExtraKey(productList);
    final bool? extraReverse = _getExtraReverse(productList);
    if (extraKey == null || extraReverse == null) {
      return null;
    }
    final LinkedHashMap<String, ProductExtra> extras =
        await getOrderedProductExtras(
      key: extraKey,
      reverse: extraReverse,
      limit: limit,
    );
    final List<String> barcodes = List<String>.from(extras.keys);
    return barcodes;
  }
}
