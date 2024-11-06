import 'dart:async';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/abstract_sql_dao.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:sqflite/sqflite.dart';

/// DAO about OSM locations.
class DaoOsmLocation extends AbstractSqlDao {
  DaoOsmLocation(super.localDatabase);

  static const String _table = 'osm_location';
  static const String _columnId = 'osm_id';
  static const String _columnType = 'osm_type';
  static const String _columnLongitude = 'longitude';
  static const String _columnLatitude = 'latitude';
  static const String _columnName = 'name';
  static const String _columnStreet = 'street';
  static const String _columnCity = 'city';
  static const String _columnPostCode = 'post_code';
  static const String _columnCountry = 'country';
  static const String _columnCountryCode = 'country_code';
  static const String _columnOsmKey = 'osm_key';
  static const String _columnOsmValue = 'osm_value';
  static const String _columnLastAccess = 'last_access';

  static const List<String> _columns = <String>[
    _columnId,
    _columnType,
    _columnLongitude,
    _columnLatitude,
    _columnName,
    _columnStreet,
    _columnCity,
    _columnPostCode,
    _columnCountry,
    _columnCountryCode,
    _columnOsmKey,
    _columnOsmValue,
    _columnLastAccess,
  ];

  static FutureOr<void> onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    if (oldVersion < 6) {
      await db.execute('create table $_table('
          ' $_columnId INT NOT NULL'
          ',$_columnType TEXT NOT NULL'
          ',$_columnLongitude REAL NOT NULL'
          ',$_columnLatitude REAL NOT NULL'
          ',$_columnName TEXT'
          ',$_columnStreet TEXT'
          ',$_columnCity TEXT'
          ',$_columnPostCode TEXT'
          ',$_columnCountry TEXT'
          ',$_columnCountryCode TEXT'
          ',$_columnLastAccess INT NOT NULL'
          // cf. https://www.sqlite.org/lang_conflict.html
          ',PRIMARY KEY($_columnId,$_columnType) on conflict replace'
          ')');
    }

    /// Not brilliant, but for historical reasons we have to catch that here.
    bool isDuplicateColumnException(
      final DatabaseException e,
      final String column,
    ) =>
        e.toString().startsWith(
            'DatabaseException(duplicate column name: $column (code 1 SQLITE_ERROR)');

    if (oldVersion < 7) {
      try {
        await db.execute('alter table $_table add column $_columnOsmKey TEXT');
      } on DatabaseException catch (e) {
        if (!isDuplicateColumnException(e, _columnOsmKey)) {
          rethrow;
        }
      }
      try {
        await db
            .execute('alter table $_table add column $_columnOsmValue TEXT');
      } on DatabaseException catch (e) {
        if (!isDuplicateColumnException(e, _columnOsmValue)) {
          rethrow;
        }
      }
    }
  }

  /// Deletes the [OsmLocation] that matches the key.
  Future<int> delete(final OsmLocation osmLocation) async =>
      localDatabase.database.delete(
        _table,
        where: '$_columnId = ? AND $_columnType = ?',
        whereArgs: <Object>[osmLocation.osmId, osmLocation.osmType.offTag],
      );

  /// Returns all the [OsmLocation]s, ordered by descending last access.
  Future<List<OsmLocation>> getAll() async {
    final List<OsmLocation> result = <OsmLocation>[];
    final List<Map<String, dynamic>> queryResults =
        await localDatabase.database.query(
      _table,
      columns: _columns,
      orderBy: '$_columnLastAccess DESC',
    );
    for (final Map<String, dynamic> row in queryResults) {
      final OsmLocation? item = _getItemFromQueryResult(row);
      if (item != null) {
        result.add(item);
      }
    }
    return result;
  }

  Future<int> put(final OsmLocation osmLocation) async =>
      localDatabase.database.insert(
        _table,
        <String, Object?>{
          _columnId: osmLocation.osmId,
          _columnType: osmLocation.osmType.offTag,
          _columnLongitude: osmLocation.longitude,
          _columnLatitude: osmLocation.latitude,
          _columnName: osmLocation.name,
          _columnStreet: osmLocation.street,
          _columnCity: osmLocation.city,
          _columnPostCode: osmLocation.postcode,
          _columnCountry: osmLocation.country,
          _columnCountryCode: osmLocation.countryCode,
          _columnOsmKey: osmLocation.osmKey,
          _columnOsmValue: osmLocation.osmValue,
          _columnLastAccess: LocalDatabase.nowInMillis(),
        },
      );

  OsmLocation? _getItemFromQueryResult(final Map<String, dynamic> row) {
    final LocationOSMType? type =
        LocationOSMType.fromOffTag(row[_columnType] as String);
    if (type == null) {
      // very very unlikely
      return null;
    }
    return OsmLocation(
      osmId: row[_columnId] as int,
      osmType: type,
      longitude: row[_columnLongitude] as double,
      latitude: row[_columnLatitude] as double,
      name: row[_columnName] as String?,
      street: row[_columnStreet] as String?,
      city: row[_columnCity] as String?,
      postcode: row[_columnPostCode] as String?,
      country: row[_columnCountry] as String?,
      countryCode: row[_columnCountryCode] as String?,
      osmKey: row[_columnOsmKey] as String?,
      osmValue: row[_columnOsmValue] as String?,
    );
  }
}
