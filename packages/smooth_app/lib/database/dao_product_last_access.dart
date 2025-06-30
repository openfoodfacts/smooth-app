import 'dart:async';
import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite/sqflite.dart';

/// Table that stores the local last access timestamp for a product.
class DaoProductLastAccess extends AbstractSqlDao {
  DaoProductLastAccess(super.localDatabase);

  static const String TABLE = 'product_last_access';
  static const String COLUMN_BARCODE = 'barcode';
  static const String COLUMN_LAST_ACCESS = 'last_access';

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 5) {
      await db.execute(
        'create table $TABLE('
        // cf. https://www.sqlite.org/lang_conflict.html
        '$COLUMN_BARCODE TEXT PRIMARY KEY on conflict replace'
        ',$COLUMN_LAST_ACCESS INT NOT NULL'
        ')',
      );
    }
  }

  Future<void> put(final String barcode) async =>
      localDatabase.database.rawInsert(
        'insert into $TABLE($COLUMN_BARCODE, $COLUMN_LAST_ACCESS) '
        'values(?, ?)',
        <Object>[barcode, LocalDatabase.nowInMillis()],
      );

  /// Delete all items from the database
  Future<int> deleteAll() async => localDatabase.database.delete(TABLE);
}
