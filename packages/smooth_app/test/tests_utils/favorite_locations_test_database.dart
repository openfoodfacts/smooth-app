import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Uses real storage while keeping unrelated background tasks out of tests.
class FavoriteLocationsTestDatabase extends Mock
    with ChangeNotifier
    implements LocalDatabase {
  FavoriteLocationsTestDatabase(this.database);

  @override
  final Database database;
}

class FavoriteLocationsTestStorage {
  late Directory directory;
  late FavoriteLocationsTestDatabase localDatabase;
  bool _inMemory = false;

  Future<void> init({bool inMemory = false}) async {
    _inMemory = inMemory;
    directory = await Directory.systemTemp.createTemp('favorite_locations_');
    await open();
  }

  Future<void> open() async {
    sqfliteFfiInit();
    Hive.init(directory.path);
    localDatabase = FavoriteLocationsTestDatabase(
      await databaseFactoryFfiNoIsolate.openDatabase(
        '${directory.path}/locations.db',
        options: OpenDatabaseOptions(
          version: 9,
          onUpgrade: DaoOsmLocation.onUpgrade,
        ),
      ),
    );
    if (_inMemory) {
      await Hive.openBox<List<String>>('stringList', bytes: Uint8List(0));
    } else {
      await DaoStringList(localDatabase).init();
    }
  }

  Future<void> close() async {
    localDatabase.dispose();
    await localDatabase.database.close();
    await Hive.close();
  }

  Future<void> delete() async {
    await close();
    await directory.delete(recursive: true);
  }
}
