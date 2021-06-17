import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smooth_app/database/local_database.dart';

/// DAO abstraction
abstract class AbstractDao {
  AbstractDao(this.localDatabase);

  final LocalDatabase localDatabase;

  /// Max number of parameters in a SQFlite query
  ///
  /// cf. SQLITE_MAX_VARIABLE_NUMBER, "which defaults to 999"
  // TODO(monsieurtanuki): find a way to retrieve this number from SQFlite system tables, cf. https://github.com/tekartik/sqflite/issues/663
  static const int SQLITE_MAX_VARIABLE_NUMBER = 999;

  /// Optimized bulk insert
  @protected
  Future<void> bulkInsert(
    final List<dynamic> parameters,
    final DatabaseExecutor databaseExecutor,
  ) async {
    final String tableName = getTableName();
    final List<String> columnNames = getBulkInsertColumns();
    final int numCols = columnNames.length;
    if (parameters.isEmpty) {
      return;
    }
    if (columnNames.isEmpty) {
      throw Exception('There must be at least one column!');
    }
    final String variables = '?${',?' * (columnNames.length - 1)}';
    if (parameters.length % numCols != 0) {
      throw Exception(
          'Parameter list size (${parameters.length}) cannot be divided by $numCols');
    }
    final int additionalRecordsNumber = -1 + parameters.length ~/ numCols;
    await databaseExecutor.rawInsert(
        'insert into $tableName(${columnNames.join(',')}) '
        'values($variables)${',($variables)' * additionalRecordsNumber}',
        parameters);
  }

  /// Optimized bulk upsert
  ///
  /// In tests it looked 33% faster to use delete/insert rather than upsert
  @protected
  Future<void> bulkUpsert({
    @required final List<dynamic> insertParameters,
    @required final String deleteWhere,
    @required final List<String> deleteParameters,
    @required final DatabaseExecutor databaseExecutor,
  }) async {
    final String tableName = getTableName();
    final List<String> insertColumns = getBulkInsertColumns();
    if (insertParameters.isEmpty) {
      return;
    }
    final int numCols = insertColumns.length;
    if (insertParameters.length % numCols != 0) {
      throw Exception(
          'Parameter list size (${insertParameters.length}) cannot be divided by $numCols');
    }
    await databaseExecutor.delete(
      tableName,
      where: deleteWhere,
      whereArgs: deleteParameters,
    );
    await bulkInsert(insertParameters, databaseExecutor);
  }

  /// Insert columns for bulk mode
  List<String> getBulkInsertColumns();

  /// Table name
  String getTableName();

  /// Max number of records to be inserted in bulk mode
  int getBulkMaxRecordNumber() =>
      SQLITE_MAX_VARIABLE_NUMBER ~/ getBulkInsertColumns().length;
}
