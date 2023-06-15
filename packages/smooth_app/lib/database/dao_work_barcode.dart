import 'dart:async';

import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:sqflite/sqflite.dart';

/// Work table that contains barcodes.
///
/// The typical use case is for bulk product downloads.
/// The first step would be to populate this table with the barcodes you're
/// interested in, e.g. all the local barcodes or the top 1k barcodes.
/// The second step would be to download the products referenced in that table.
class DaoWorkBarcode extends AbstractSqlDao {
  DaoWorkBarcode(super.localDatabase);

  static const String _table = 'work_barcode';
  static const String _columnWork = 'work';
  static const String _columnBarcode = 'barcode';

  static const List<String> _columns = <String>[
    _columnWork,
    _columnBarcode,
  ];

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 3) {
      await db.execute('create table $_table('
          '$_columnWork TEXT NOT NULL'
          ',$_columnBarcode TEXT NOT NULL'
          // cf. https://www.sqlite.org/lang_conflict.html
          ',PRIMARY KEY($_columnWork,$_columnBarcode) on conflict replace'
          ')');
    }
  }

  /// Returns the number of barcodes for that work.
  Future<int> getCount(final String work) async {
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      _table,
      columns: <String>['count(1) as my_count'],
      where: '$_columnWork = ?',
      whereArgs: <String>[work],
    );
    for (final Map<String, dynamic> row in queryResults) {
      return row['my_count'] as int;
    }
    // not expected
    return 0;
  }

  /// Returns the next barcodes for that work.
  Future<List<String>> getNextPage(
    final String work,
    final int pageSize,
  ) async {
    final List<String> result = <String>[];
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      _table,
      columns: <String>[_columnBarcode],
      where: '$_columnWork = ?',
      whereArgs: <String>[work],
      limit: pageSize,
    );
    for (final Map<String, dynamic> row in queryResults) {
      result.add(row[_columnBarcode] as String);
    }
    return result;
  }

  Future<void> putAll(
    final String work,
    final Iterable<String> barcodes,
  ) async =>
      localDatabase.database.transaction(
        (final Transaction transaction) async =>
            _bulkInsert(transaction, work, barcodes),
      );

  /// Returns the number of inserted rows by optimized bulk insert.
  // TODO(monsieurtanuki): will work for less than 999 / 2 = 499 barcodes
  Future<int> _bulkInsert(
    final DatabaseExecutor databaseExecutor,
    final String work,
    final Iterable<String> barcodes,
  ) async {
    if (barcodes.isEmpty) {
      return 0;
    }
    final List<String> parameters = <String>[];
    for (final String barcode in barcodes) {
      parameters.add(work);
      parameters.add(barcode);
    }
    return databaseExecutor.rawInsert(
      'insert into $_table(${_columns.join(',')}) '
      'values(?,?)${',(?,?)' * (barcodes.length - 1)}',
      parameters,
    );
  }

  /// Deletes all barcodes for a given work.
  ///
  /// Returns the number of rows deleted.
  Future<int> deleteWork(final String work) async =>
      localDatabase.database.delete(
        _table,
        where: '$_columnWork = ?',
        whereArgs: <String>[work],
      );

  /// Deletes all barcodes for a given work.
  ///
  /// Returns the number of rows deleted.
  // TODO(monsieurtanuki): will work for less than 999 - 1 = 998 barcodes
  Future<int> deleteBarcodes(
    final String work,
    final Iterable<String> barcodes,
  ) async {
    if (barcodes.isEmpty) {
      return 0;
    }
    final List<String> parameters = <String>[];
    parameters.add(work);
    parameters.addAll(barcodes);
    return localDatabase.database.delete(
      _table,
      where:
          '$_columnWork = ? and barcode in(?${',?' * (barcodes.length - 1)})',
      whereArgs: parameters,
    );
  }
}
