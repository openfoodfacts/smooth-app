import 'dart:async';

import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/bulk_manager.dart';
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

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 3) {
      await db.execute(
        'create table $_table('
        '$_columnWork TEXT NOT NULL'
        ',$_columnBarcode TEXT NOT NULL'
        // cf. https://www.sqlite.org/lang_conflict.html
        ',PRIMARY KEY($_columnWork,$_columnBarcode) on conflict replace'
        ')',
      );
    }
  }

  /// Returns the number of barcodes for that work.
  Future<int> getCount(final String work) async {
    final List<Map<String, dynamic>> queryResults = await localDatabase.database
        .query(
          _table,
          columns: <String>['count(1) as my_count'],
          where: '$_columnWork = ?',
          whereArgs: <String>[work],
        );
    for (final Map<String, dynamic> row in queryResults) {
      return row['my_count'] as int;
    }
    throw Exception('Cannot count table $_table for work $work');
  }

  /// Returns the next barcodes for that work.
  Future<List<String>> getNextPage(
    final String work,
    final int pageSize,
  ) async {
    final List<String> result = <String>[];
    final List<Map<String, dynamic>> queryResults = await localDatabase.database
        .query(
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

  /// Returns the number of inserted rows.
  Future<int> putAll(
    final String work,
    final Iterable<String> barcodes,
  ) async => localDatabase.database.transaction(
    (final Transaction transaction) async =>
        _bulkInsert(transaction, work, barcodes),
  );

  /// Returns the number of inserted rows by optimized bulk insert.
  Future<int> _bulkInsert(
    final DatabaseExecutor databaseExecutor,
    final String work,
    final Iterable<String> barcodes,
  ) async {
    if (barcodes.isEmpty) {
      return 0;
    }
    final List<String> parameters = <String>[];
    int count = 0;

    Future<void> rawInsert() async {
      if (parameters.isEmpty) {
        return;
      }
      final int inserted = parameters.length ~/ 2;
      await databaseExecutor.rawInsert(
        'insert into $_table($_columnWork,$_columnBarcode) '
        'values(?,?)${',(?,?)' * (inserted - 1)}',
        parameters,
      );
      count += inserted;
    }

    for (final String barcode in barcodes) {
      parameters.add(work);
      parameters.add(barcode);
      if (parameters.length + 2 >= BulkManager.SQLITE_MAX_VARIABLE_NUMBER) {
        await rawInsert();
        parameters.clear();
      }
    }
    await rawInsert();
    return count;
  }

  /// Deletes all barcodes for a given work.
  ///
  /// Returns the number of rows deleted.
  Future<int> deleteWork(final String work) async => localDatabase.database
      .delete(_table, where: '$_columnWork = ?', whereArgs: <String>[work]);

  /// Deletes all barcodes for a given work.
  ///
  /// Returns the number of rows deleted.
  Future<int> deleteBarcodes(
    final String work,
    final Iterable<String> barcodes,
  ) async => localDatabase.database.transaction(
    (final Transaction transaction) async =>
        _bulkDelete(transaction, work, barcodes),
  );

  /// Returns the number of deleted rows by optimized bulk delete.
  Future<int> _bulkDelete(
    final DatabaseExecutor databaseExecutor,
    final String work,
    final Iterable<String> barcodes,
  ) async {
    if (barcodes.isEmpty) {
      return 0;
    }
    final List<String> parameters = <String>[];
    int count = 0;

    Future<void> rawDelete() async {
      if (parameters.length < 2) {
        return;
      }
      final int deleted = await databaseExecutor.delete(
        _table,
        where:
            '$_columnWork = ? '
            'and $_columnBarcode in(?${',?' * (parameters.length - 2)})',
        whereArgs: parameters,
      );
      count += deleted;
    }

    parameters.add(work);
    for (final String barcode in barcodes) {
      parameters.add(barcode);
      if (parameters.length + 1 >= BulkManager.SQLITE_MAX_VARIABLE_NUMBER) {
        await rawDelete();
        parameters.clear();
        parameters.add(work);
      }
    }
    await rawDelete();
    return count;
  }
}
