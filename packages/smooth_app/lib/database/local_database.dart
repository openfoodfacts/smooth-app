import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_hive_product.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/dao_product_migration.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/dao_string_list_map.dart';
import 'package:smooth_app/database/dao_unzipped_product.dart';
import 'package:sqflite/sqflite.dart';

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
    // sql from there
    final String databasesRootPath;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // as suggested in https://pub.dev/documentation/sqflite/latest/sqflite/getDatabasesPath.html
      final Directory directory = await getLibraryDirectory();
      databasesRootPath = directory.path;
    } else {
      databasesRootPath = await getDatabasesPath();
    }
    final String databasePath = join(databasesRootPath, 'smoothie.db');
    final Database database = await openDatabase(
      databasePath,
      version: 2,
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
      DaoInt(localDatabase),
      DaoStringListMap(localDatabase),
    ];
    for (final AbstractDao dao in daos) {
      dao.registerAdapter();
    }
    for (final AbstractDao dao in daos) {
      await dao.init();
    }

    // Migrations here
    await DaoProductMigration.migrate(
      source: DaoHiveProduct(localDatabase),
      destination: DaoUnzippedProduct(localDatabase),
    );
    await DaoProductMigration.migrate(
      source: DaoUnzippedProduct(localDatabase),
      destination: DaoProduct(localDatabase),
    );

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
    await DaoUnzippedProduct.onUpgrade(db, oldVersion, newVersion);
    await DaoProduct.onUpgrade(db, oldVersion, newVersion);
  }
}
