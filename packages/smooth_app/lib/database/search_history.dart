import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class SearchHistory extends ChangeNotifier {
  SearchHistory(this.db);

  static const int maxSize = 5;

  final Database db;
  static const String _tableName = 'search_history';
  static const String _columnId = 'id';
  static const String _columnQuery = 'query';

  static Future<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 9) {
      return db.execute('''
        CREATE TABLE $_tableName(
          $_columnId INTEGER PRIMARY KEY,
          $_columnQuery TEXT NOT NULL UNIQUE
        )
      ''');
    }
  }

  Future<List<String>> getAllQueries() async {
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      columns: <String>[_columnQuery],
      orderBy: '$_columnId DESC',
    );
    return rows
        .map((Map<String, Object?> row) => row[_columnQuery]! as String)
        .toList();
  }

  Future<void> add(String query) async {
    await db.insert(
      _tableName,
      <String, String>{
        _columnQuery: query,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Only keep [maxSize] rows in the table.
    await db.rawDelete('''
      DELETE FROM $_tableName
      WHERE $_columnId NOT IN (
        SELECT $_columnId
        FROM $_tableName
        ORDER BY $_columnId DESC
        LIMIT ?
      )
    ''', <int>[maxSize]);
    notifyListeners();
  }

  Future<void> remove(String query) async {
    await db.delete(
      _tableName,
      where: '$_columnQuery = ?',
      whereArgs: <String>[query],
    );
    notifyListeners();
  }
}
