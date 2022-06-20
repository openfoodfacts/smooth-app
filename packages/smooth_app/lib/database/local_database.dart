import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_hive_product.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/dao_string_list_map.dart';
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
    final String databasePath = await _getDatabasePath();
    final Database database = await openDatabase(
      databasePath,
      version: 1,
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

    // Migration here
    await _migrate(localDatabase);

    return localDatabase;
  }

  static Future<String> _getDatabasePath() async {
    final String databasesRootPath;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // as suggested in https://pub.dev/documentation/sqflite/latest/sqflite/getDatabasesPath.html
      final Directory directory = await getLibraryDirectory();
      databasesRootPath = directory.path;
    } else {
      databasesRootPath = await getDatabasesPath();
    }
    return join(databasesRootPath, 'smoothie.db');
  }

  static Future<void> _migrate(final LocalDatabase localDatabase) async {
    final DaoHiveProduct daoHiveProduct = DaoHiveProduct(localDatabase);
    final List<String> barcodesFrom = await daoHiveProduct.getAllKeys();
    if (barcodesFrom.isEmpty) {
      // nothing to migrate, or already migrated and cleaned.
      return;
    }

    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final List<String> barcodesAlreadyThere = await daoProduct.getAllKeys();

    final List<String> barcodesToBeCopied = List<String>.from(barcodesFrom);
    barcodesToBeCopied.removeWhere(
        (final String barcode) => barcodesAlreadyThere.contains(barcode));

    if (barcodesToBeCopied.isNotEmpty) {
      final Map<String, Product> copiedProducts =
          await daoHiveProduct.getAll(barcodesToBeCopied);
      await daoProduct.putAll(copiedProducts.values);
      final List<String> barcodesFinallyThere = await daoProduct.getAllKeys();
      if (barcodesFinallyThere.length !=
          barcodesAlreadyThere.length + barcodesToBeCopied.length) {
        // unexpected
        return;
      }
    }

    // cleaning the old product table
    await daoHiveProduct.deleteAll(barcodesFrom);
    final List<String> barcodesNoMore = await daoProduct.getAllKeys();
    if (barcodesNoMore.isNotEmpty) {
      // unexpected
    }
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
  }

  //Returns the approximate size of the database in MB
  Future<double> getSize() async {
    final String path = await _getDatabasePath();
    final File file = File(path);
    final double size = file.lengthSync() / 1024 / 1024;
    return double.parse(size.toStringAsFixed(1));
  }
}
