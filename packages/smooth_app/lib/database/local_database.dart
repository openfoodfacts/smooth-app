import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_provider.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_hive_product.dart';
import 'package:smooth_app/database/dao_instant_string.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_last_access.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/dao_string_list_map.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/dao_work_barcode.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase extends ChangeNotifier {
  LocalDatabase._(final Database database) : _database = database {
    _upToDateProductProvider = UpToDateProductProvider(this);
    _upToDateProductListProvider = UpToDateProductListProvider(this);
  }

  final Database _database;
  late final UpToDateProductProvider _upToDateProductProvider;
  late final UpToDateProductListProvider _upToDateProductListProvider;

  Database get database => _database;

  UpToDateProductProvider get upToDate => _upToDateProductProvider;
  UpToDateProductListProvider get upToDateProductList =>
      _upToDateProductListProvider;

  @override
  void notifyListeners() {
    BackgroundTaskManager.runAgain(this);
    super.notifyListeners();
  }

  /// Returns all the pending background task ids.
  ///
  /// Ugly solution to be able to mock hive data.
  List<String> getAllTaskIds(final String key) =>
      DaoStringList(this).getAll(key);

  /// Ugly solution to be able to mock hive data.
  int? daoIntGet(final String key) => DaoInt(this).get(key);

  /// Ugly solution to be able to mock hive data.
  Future<void> daoIntPut(final String key, final int? value) =>
      DaoInt(this).put(key, value);

  static Future<LocalDatabase> getLocalDatabase() async {
    // sql from there
    String? databasesRootPath;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // as suggested in https://pub.dev/documentation/sqflite/latest/sqflite/getDatabasesPath.html
      final Directory directory = await getLibraryDirectory();
      databasesRootPath = directory.path;
    } else if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    databasesRootPath ??= await getDatabasesPath();

    final String databasePath = join(databasesRootPath, 'smoothie.db');
    final Database database = await openDatabase(
      databasePath,
      version: 7,
      singleInstance: true,
      onUpgrade: _onUpgrade,
    );

    final LocalDatabase localDatabase = LocalDatabase._(database);

    // only hive from there
    await Hive.initFlutter();
    final List<AbstractDao> daos = <AbstractDao>[
      DaoHiveProduct(localDatabase),
      DaoProductList(localDatabase),
      DaoStringList(localDatabase),
      DaoString(localDatabase),
      DaoInstantString(localDatabase),
      DaoInt(localDatabase),
      DaoStringListMap(localDatabase),
      DaoTransientOperation(localDatabase),
    ];
    for (final AbstractDao dao in daos) {
      dao.registerAdapter();
    }
    for (final AbstractDao dao in daos) {
      await dao.init();
    }

    // Migrations here
    // (no migration for the moment)

    return localDatabase;
  }

  static int nowInMillis() => DateTime.now().millisecondsSinceEpoch;

  /// we don't use onCreate and onUpgrade, we use only onUpgrade instead.
  /// checked: from scratch, onUpgrade is called with oldVersion = 0.
  static FutureOr<void> _onUpgrade(
    final Database db,
    final int oldVersion,
    final int newVersion,
  ) async {
    await DaoProduct.onUpgrade(db, oldVersion, newVersion);
    await DaoWorkBarcode.onUpgrade(db, oldVersion, newVersion);
    await DaoProductLastAccess.onUpgrade(db, oldVersion, newVersion);
    await DaoOsmLocation.onUpgrade(db, oldVersion, newVersion);
  }
}
