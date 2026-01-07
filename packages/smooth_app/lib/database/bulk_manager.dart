import 'dart:async';
import 'dart:math';

import 'package:smooth_app/database/bulk_deletable.dart';
import 'package:smooth_app/database/bulk_insertable.dart';
import 'package:sqflite/sqflite.dart';

/// Manager for bulk database inserts and deletes.
///
/// In tests it looked 33% faster to use delete/insert rather than upsert
/// And of course it's much faster to perform bulk actions
/// rather than numerous single actions
/// cf. [BulkInsertable], [BulkDeletable]
class BulkManager {
  /// Max number of parameters in a SQFlite query
  ///
  /// cf. SQLITE_MAX_VARIABLE_NUMBER, "which defaults to 999"
  // TODO(monsieurtanuki): find a way to retrieve this number from SQFlite system tables, cf. https://github.com/tekartik/sqflite/issues/663
  static const int SQLITE_MAX_VARIABLE_NUMBER = 999;

  /// Returns the number of inserted rows by optimized bulk insert
  Future<int> insert({
    required final BulkInsertable bulkInsertable,
    required final List<dynamic> parameters,
    required final DatabaseExecutor databaseExecutor,
  }) async {
    int result = 0;
    final String tableName = bulkInsertable.getTableName();
    final List<String> columnNames = bulkInsertable.getInsertColumns();
    final int numCols = columnNames.length;
    if (parameters.isEmpty) {
      return result;
    }
    if (columnNames.isEmpty) {
      throw Exception('There must be at least one column!');
    }
    if (parameters.length % numCols != 0) {
      throw Exception(
        'Parameter list size (${parameters.length}) cannot be divided by $numCols',
      );
    }
    final String variables = '?${',?' * (columnNames.length - 1)}';
    final int maxSlice = (SQLITE_MAX_VARIABLE_NUMBER ~/ numCols) * numCols;
    for (int start = 0; start < parameters.length; start += maxSlice) {
      final int size = min(parameters.length - start, maxSlice);
      final int insertedRows = size ~/ numCols;
      final int additionalRecordsNumber = -1 + insertedRows;
      await databaseExecutor.rawInsert(
        'insert into $tableName(${columnNames.join(',')}) '
        'values($variables)${',($variables)' * additionalRecordsNumber}',
        parameters.sublist(start, start + size),
      );
      result += insertedRows;
    }
    return result;
  }

  /// Returns the number of deleted rows by optimized bulk delete
  Future<int> delete({
    required final BulkDeletable bulkDeletable,
    required final List<dynamic> parameters,
    required final DatabaseExecutor databaseExecutor,
    final List<dynamic>? additionalParameters,
  }) async {
    int result = 0;
    final String tableName = bulkDeletable.getTableName();
    if (parameters.isEmpty) {
      return result;
    }
    final int maxSlice =
        SQLITE_MAX_VARIABLE_NUMBER - (additionalParameters?.length ?? 0);
    for (int start = 0; start < parameters.length; start += maxSlice) {
      final int size = min(parameters.length - start, maxSlice);
      final List<dynamic> currentParameters = <dynamic>[];
      if (additionalParameters != null && additionalParameters.isNotEmpty) {
        currentParameters.addAll(additionalParameters);
      }
      currentParameters.addAll(parameters.sublist(start, start + size));
      final int deleted = await databaseExecutor.delete(
        tableName,
        where: bulkDeletable.getDeleteWhere(currentParameters),
        whereArgs: currentParameters,
      );
      result += deleted;
    }
    return result;
  }
}
