import 'dart:async';
import 'dart:convert';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaoFolksonomy extends AbstractSqlDao {
  DaoFolksonomy(super.localDatabase);

  static const String _table = 'folksonomy';
  static const String _columnBarcode = 'barcode';
  static const String _columnTags = 'tagsString';
  static const String _columnLastUpdateTimestamp = 'lastUpdateTimeStamp';

  static const List<String> _columns = <String>[
    _columnBarcode,
    _columnTags,
    _columnLastUpdateTimestamp,
  ];

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 9) {
      await db.execute(
        'create table $_table('
        ' $_columnBarcode TEXT NOT NULL PRIMARY KEY ON CONFLICT REPLACE,'
        ' $_columnTags TEXT NOT NULL,'
        ' $_columnLastUpdateTimestamp INT NOT NULL'
        ')',
      );
    }
  }

  Future<void> put(final String barcode, final List<ProductTag>? tags) async {
    if (tags == null) {
      await localDatabase.database.delete(
        _table,
        where: '$_columnBarcode = ?',
        whereArgs: <String>[barcode],
      );
      return;
    }

    final String tagsString = jsonEncode(
      tags.map((ProductTag tag) => tag.toJson()).toList(),
    );
    await localDatabase.database.insert(_table, <String, dynamic>{
      _columnBarcode: barcode,
      _columnTags: tagsString,
      _columnLastUpdateTimestamp: LocalDatabase.nowInMillis(),
    });
  }

  Future<List<ProductTag>?> get(final String barcode) async {
    final List<Map<String, dynamic>> result = await localDatabase.database
        .query(
          _table,
          columns: _columns,
          where: '$_columnBarcode = ?',
          whereArgs: <String>[barcode],
        );

    if (result.isEmpty) {
      return null;
    }

    final List<dynamic> tags =
        jsonDecode(result.first[_columnTags] as String) as List<dynamic>;
    return tags
        .map(
          (dynamic json) => ProductTag.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
