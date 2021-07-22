// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/dao_product_extra.dart';

class LocalDatabase extends ChangeNotifier {
  LocalDatabase._(final Database database) : _database = database;

  final Database _database;

  Database get database => _database;

  /// Notify listeners
  /// Comments added only in order to avoid a "warning"
  /// For the record, we need to override the method
  /// because the parent's is protected
  @override
  void notifyListeners() => super.notifyListeners();

  static Future<LocalDatabase> getLocalDatabase() async {
    final String databasesRootPath = await getDatabasesPath();
    final String databasePath = join(databasesRootPath, 'smoothie.db');

    final Database database = await openDatabase(
      databasePath,
      version: 8,
      singleInstance: true,
      onUpgrade: _onUpgrade,
    );

    return LocalDatabase._(database);
  }

  static const String COLUMN_TIMESTAMP = 'last_upsert';

  /// we don't use onCreate and onUpgrade, we use only onUpgrade instead
  /// checked: from scratch, onUpgrade is called with oldVersion = 0
  static FutureOr<void> _onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    await DaoProduct.onUpgrade(db, oldVersion, newVersion);
    await DaoProductExtra.onUpgrade(db, oldVersion, newVersion);
    await DaoProductList.onUpgrade(db, oldVersion, newVersion);
  }

  static int nowInMillis() => DateTime.now().millisecondsSinceEpoch;

  static DateTime timestampToDateTime(final int timestampInMillis) =>
      DateTime.fromMillisecondsSinceEpoch(timestampInMillis);
}

class TableStats {
  TableStats({
    required this.tableName,
    required this.count,
    required this.minTimestamp,
    required this.maxTimestamp,
  });

  final String tableName;
  final int count;
  final int minTimestamp;
  final int maxTimestamp;

  static Future<TableStats> getTableStats(
    final LocalDatabase localDatabase,
    final String tableName,
  ) async {
    const String COLUMN_COUNT = 'mycount';
    const String COLUMN_MIN = 'mymin';
    const String COLUMN_MAX = 'mymax';

    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.query(
      tableName,
      columns: <String>[
        'count(*) as $COLUMN_COUNT',
        'max(${LocalDatabase.COLUMN_TIMESTAMP}) as $COLUMN_MAX',
        'min(${LocalDatabase.COLUMN_TIMESTAMP}) as $COLUMN_MIN',
      ],
    );
    if (queryResult.isEmpty || queryResult.length > 1) {
      // very very unlikely to happen
      throw Exception('No stats for table $tableName');
    }
    final Map<String, dynamic> uniqueRow = queryResult[0];
    return TableStats(
      tableName: tableName,
      count: uniqueRow[COLUMN_COUNT] as int,
      minTimestamp: uniqueRow[COLUMN_MIN] as int,
      maxTimestamp: uniqueRow[COLUMN_MAX] as int,
    );
  }

  @override
  String toString() => 'TableStats('
      'tableName: $tableName'
      ','
      'count: $count'
      ','
      'minTimestamp: ${DateTime.fromMillisecondsSinceEpoch(minTimestamp)}'
      ','
      'maxTimestamp: ${DateTime.fromMillisecondsSinceEpoch(maxTimestamp)}'
      ')';
}
