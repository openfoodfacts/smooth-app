import 'dart:async';
import 'dart:convert';

import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaoNamespace extends AbstractSqlDao {
  DaoNamespace(super.localDatabase);

  static const String _TABLE_NAMESPACE = 'autocomplete_namespace';
  static const String _TABLE_NAMESPACE_COLUMN_ID = 'id';
  static const String _TABLE_NAMESPACE_COLUMN_NAMESPACE = 'namespace';

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 10) {
      await db.execute(
        'create table $_TABLE_NAMESPACE('
        '$_TABLE_NAMESPACE_COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT'
        ',$_TABLE_NAMESPACE_COLUMN_NAMESPACE TEXT NOT NULL UNIQUE'
        ')',
      );
    }
  }

  /// Returns the namespace id for the given [namespace] string.
  Future<int> getOrCreateId(final String namespace) async {
    final List<Map<String, dynamic>> rows = await localDatabase.database.query(
      _TABLE_NAMESPACE,
      columns: <String>[_TABLE_NAMESPACE_COLUMN_ID],
      where: '$_TABLE_NAMESPACE_COLUMN_NAMESPACE = ?',
      whereArgs: <String>[namespace],
    );
    if (rows.isNotEmpty) {
      return rows.first[_TABLE_NAMESPACE_COLUMN_ID] as int;
    }
    return localDatabase.database.insert(_TABLE_NAMESPACE, <String, dynamic>{
      _TABLE_NAMESPACE_COLUMN_NAMESPACE: namespace,
    });
  }
}

class DaoAutocompleteCache extends AbstractSqlDao {
  DaoAutocompleteCache(super.localDatabase);

  static const String _TABLE_CACHE = 'autocomplete_cache';
  static const String _TABLE_CACHE_COLUMN_NAMESPACE_ID = 'namespace_id';
  static const String _TABLE_CACHE_COLUMN_QUERY = 'query';
  static const String _TABLE_CACHE_COLUMN_RESULTS = 'results';
  static const String _TABLE_CACHE_COLUMN_LAST_UPDATE = 'last_update';

  static const List<String> _columnsCache = <String>[
    _TABLE_CACHE_COLUMN_NAMESPACE_ID,
    _TABLE_CACHE_COLUMN_QUERY,
    _TABLE_CACHE_COLUMN_RESULTS,
    _TABLE_CACHE_COLUMN_LAST_UPDATE,
  ];

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 10) {
      await db.execute(
        'create table $_TABLE_CACHE('
        '$_TABLE_CACHE_COLUMN_NAMESPACE_ID INTEGER NOT NULL'
        ',$_TABLE_CACHE_COLUMN_QUERY TEXT NOT NULL'
        ',$_TABLE_CACHE_COLUMN_RESULTS TEXT NOT NULL'
        ',$_TABLE_CACHE_COLUMN_LAST_UPDATE INTEGER NOT NULL'
        ',PRIMARY KEY'
        '($_TABLE_CACHE_COLUMN_NAMESPACE_ID'
        ',$_TABLE_CACHE_COLUMN_QUERY) ON CONFLICT REPLACE'
        ')',
      );
    }
  }

  /// Returns cached results for [namespaceId] and [query].
  /// Returns null if not found.
  Future<List<String>?> get(final int namespaceId, final String query) async {
    final List<Map<String, dynamic>> rows = await localDatabase.database.query(
      _TABLE_CACHE,
      columns: _columnsCache,
      where:
          '$_TABLE_CACHE_COLUMN_NAMESPACE_ID = ?'
          ' AND $_TABLE_CACHE_COLUMN_QUERY = ?',
      whereArgs: <dynamic>[namespaceId, query],
    );
    if (rows.isEmpty) {
      return null;
    }
    final String json = rows.first[_TABLE_CACHE_COLUMN_RESULTS] as String;
    return (jsonDecode(json) as List<dynamic>).cast<String>();
  }

  /// Stores [results] for [namespaceId] and [query].
  Future<void> put(
    final int namespaceId,
    final String query,
    final List<String> results,
  ) async {
    await localDatabase.database.insert(_TABLE_CACHE, <String, dynamic>{
      _TABLE_CACHE_COLUMN_NAMESPACE_ID: namespaceId,
      _TABLE_CACHE_COLUMN_QUERY: query,
      _TABLE_CACHE_COLUMN_RESULTS: jsonEncode(results),
      _TABLE_CACHE_COLUMN_LAST_UPDATE: LocalDatabase.nowInMillis(),
    });
  }
}
