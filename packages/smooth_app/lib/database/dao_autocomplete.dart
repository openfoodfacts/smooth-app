import 'dart:async';
import 'dart:convert';

import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaoAutocomplete extends AbstractSqlDao {
  DaoAutocomplete(super.localDatabase);

  // autocomplete_namespace table
  static const String _TABLE_NAMESPACE = 'autocomplete_namespace';
  static const String _TABLE_NAMESPACE_COLUMN_ID = 'id';
  static const String _TABLE_NAMESPACE_COLUMN_NAMESPACE = 'namespace';

  // autocomplete_cache table
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

  /// Session-level in-memory cache for namespace string → integer id.
  /// Eliminates redundant DB lookups - there are only 7-22 namespaces
  /// for a typical user so this map stays tiny for the lifetime of the
  /// app process.
  static final Map<String, int> _namespaceCache = <String, int>{};

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
      await db.execute(
        'create index idx_namespace'
        ' on $_TABLE_NAMESPACE($_TABLE_NAMESPACE_COLUMN_NAMESPACE)',
      );
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

  /// Returns the namespace id for the given [namespace] string.
  /// Creates a new row if the namespace does not exist yet.
  /// Result is cached in memory so subsequent calls within the same
  /// app session never hit the database.
  Future<int> _getOrCreateNamespaceId(final String namespace) async {
    final int? cached = _namespaceCache[namespace];
    if (cached != null) {
      return cached;
    }
    final List<Map<String, dynamic>> rows = await localDatabase.database.query(
      _TABLE_NAMESPACE,
      columns: <String>[_TABLE_NAMESPACE_COLUMN_ID],
      where: '$_TABLE_NAMESPACE_COLUMN_NAMESPACE = ?',
      whereArgs: <String>[namespace],
    );
    final int id;
    if (rows.isNotEmpty) {
      id = rows.first[_TABLE_NAMESPACE_COLUMN_ID] as int;
    } else {
      id = await localDatabase.database.insert(
        _TABLE_NAMESPACE,
        <String, dynamic>{_TABLE_NAMESPACE_COLUMN_NAMESPACE: namespace},
      );
    }
    _namespaceCache[namespace] = id;
    return id;
  }

  /// Returns cached results for the given [namespace] and [query].
  /// Returns null if not found.
  Future<List<String>?> getResults(
    final String namespace,
    final String query,
  ) async {
    final int namespaceId = await _getOrCreateNamespaceId(namespace);
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

  /// Stores [results] for the given [namespace] and [query].
  Future<void> storeResults(
    final String namespace,
    final String query,
    final List<String> results,
  ) async {
    final int namespaceId = await _getOrCreateNamespaceId(namespace);
    await localDatabase.database.insert(_TABLE_CACHE, <String, dynamic>{
      _TABLE_CACHE_COLUMN_NAMESPACE_ID: namespaceId,
      _TABLE_CACHE_COLUMN_QUERY: query,
      _TABLE_CACHE_COLUMN_RESULTS: jsonEncode(results),
      _TABLE_CACHE_COLUMN_LAST_UPDATE: LocalDatabase.nowInMillis(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
