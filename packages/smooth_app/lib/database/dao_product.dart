// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:smooth_app/database/local_database.dart';
import 'package:diacritic/diacritic.dart';

class DaoProduct {
  DaoProduct(this.localDatabase);

  final LocalDatabase localDatabase;

  static const String TABLE_PRODUCT = 'product';
  static const String TABLE_PRODUCT_COLUMN_BARCODE = 'barcode';
  static const String _TABLE_PRODUCT_COLUMN_JSON = 'encoded_json';

  static const String _TABLE_PRODUCT_EXTRA = 'product_extra';
  static const String _TABLE_PRODUCT_EXTRA_COLUMN_KEY = 'extra_key';
  static const String _TABLE_PRODUCT_EXTRA_COLUMN_VALUE = 'extra_value';

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
    if (oldVersion < 4) {
      await db.execute('create table $_TABLE_PRODUCT_EXTRA('
          '$TABLE_PRODUCT_COLUMN_BARCODE TEXT NOT NULL,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY TEXT NOT NULL,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_VALUE TEXT NOT NULL,'
          '${LocalDatabase.COLUMN_TIMESTAMP} INT NOT NULL,'
          'PRIMARY KEY ('
          '$TABLE_PRODUCT_COLUMN_BARCODE,'
          '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY),'
          'FOREIGN KEY ($TABLE_PRODUCT_COLUMN_BARCODE)'
          ' REFERENCES $TABLE_PRODUCT'
          '  ($TABLE_PRODUCT_COLUMN_BARCODE)'
          '   ON DELETE CASCADE'
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

  /// Returns the products that match a string
  ///
  /// The search is actually ugly, but it's a start.
  // TODO(monsieurtanuki): check only the fields that are deemed relevant
  // TODO(monsieurtanuki): consider space-separated fields as distinct keywords
  Future<List<Product>> getSuggestions(
      final String pattern, final int minLength) async {
    final List<Product> result = <Product>[];
    if (pattern == null || pattern.trim().length < minLength) {
      return result;
    }
    await _initSimplifiedText();
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.rawQuery(
      'select'
      '  a.$TABLE_PRODUCT_COLUMN_BARCODE '
      ', a.$_TABLE_PRODUCT_COLUMN_JSON '
      'from '
      '  $TABLE_PRODUCT a '
      ', $_TABLE_PRODUCT_EXTRA b '
      'where '
      '  a.$TABLE_PRODUCT_COLUMN_BARCODE = b.$TABLE_PRODUCT_COLUMN_BARCODE '
      '  and b.$_TABLE_PRODUCT_EXTRA_COLUMN_KEY = ? '
      '  and b.$_TABLE_PRODUCT_EXTRA_COLUMN_VALUE like ? '
      'order by '
      '  a.${LocalDatabase.COLUMN_TIMESTAMP} desc',
      <String>[
        _EXTRA_ID_SIMPLIFIED_TEXT,
        '%${_getSimplifiedText(pattern)}%',
      ],
    );
    for (final Map<String, dynamic> row in queryResults) {
      result.add(_getProductFromQueryResult(row));
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
          await _upsertAllExtras(product, databaseExecutor);
          return true;
        }
      }
      final bool result = await _insert(product, databaseExecutor);
      if (result) {
        await _upsertAllExtras(product, databaseExecutor);
      }
      return result;
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

  /// Returns a lowercase not accented version of the text, for comparisons
  static String _getSimplifiedText(final String text) {
    if (text == null) {
      return '';
    }
    return removeDiacritics(text).toLowerCase();
  }

  static const String _EXTRA_ID_SIMPLIFIED_TEXT = 'simplified_text';

  /// Init, to be performed only during a transitional development phase
  Future<void> _initSimplifiedText() async {
    final List<Map<String, dynamic>> counting =
        await localDatabase.database.query(
      _TABLE_PRODUCT_EXTRA,
      columns: <String>['count(*) as mycount'],
      where: '$_TABLE_PRODUCT_EXTRA_COLUMN_KEY = ?',
      whereArgs: <String>[_EXTRA_ID_SIMPLIFIED_TEXT],
    );
    final int count = counting[0]['mycount'] as int;
    if (count > 0) {
      return; // already done, nothing more to do
    }
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      TABLE_PRODUCT,
      columns: <String>[
        TABLE_PRODUCT_COLUMN_BARCODE,
        _TABLE_PRODUCT_COLUMN_JSON,
      ],
    );
    if (queryResults.isEmpty) {
      return; // empty database, nothing to do at all
    }
    for (final Map<String, dynamic> row in queryResults) {
      final Product product = _getProductFromQueryResult(row);
      await _upsertAllExtras(product, localDatabase.database);
    }
  }

  /// Upserts all the extras related to a product
  ///
  /// Just one extra for the moment: the simplified text
  static Future<void> _upsertAllExtras(
    final Product product,
    final DatabaseExecutor databaseExecutor,
  ) async =>
      await _upsertExtra(
        product.barcode,
        _EXTRA_ID_SIMPLIFIED_TEXT,
        _getSimplifiedTextForProduct(product),
        databaseExecutor,
      );

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

  static Future<void> _upsertExtra(
    final String barcode,
    final String extraId,
    final String extraValue,
    final DatabaseExecutor databaseExecutor,
  ) async =>
      await databaseExecutor.insert(
        _TABLE_PRODUCT_EXTRA,
        <String, dynamic>{
          TABLE_PRODUCT_COLUMN_BARCODE: barcode,
          _TABLE_PRODUCT_EXTRA_COLUMN_KEY: extraId,
          _TABLE_PRODUCT_EXTRA_COLUMN_VALUE: extraValue,
          LocalDatabase.COLUMN_TIMESTAMP: LocalDatabase.nowInMillis(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
}
