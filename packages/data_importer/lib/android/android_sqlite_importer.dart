import 'dart:io';

import 'package:data_importer/data_importer.dart';
import 'package:data_importer/shared/model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AndroidDatabaseImporter {
  const AndroidDatabaseImporter._();

  static Future<ImportableUserData?> extract() async {
    final String path = await _getDatabasePath();

    if (!File(path).existsSync()) {
      return null;
    }

    final Database database = await openDatabase(
      path,
      version: 22,
      readOnly: true,
    );

    final ImportableProductList history =
        await _listProductsFromHistory(database);
    final ImportableUserLists lists = await _listUserLists(database);

    await database.close();

    return ImportableUserData(
      history: history,
      lists: lists,
    );
  }

  static Future<String> _getDatabasePath() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'open_food_facts');
    return path;
  }

  static Future<ImportableProductList> _listProductsFromHistory(
      Database database) async {
    final List<Map<String, Object?>> list = await database.rawQuery('''
      SELECT BARCODE 
      FROM HISTORY_PRODUCT 
      WHERE TRIM(BARCODE) != ""
      ORDER BY LAST_SEEN DESC 
      LIMIT ${ApplicationDataImporter.MAX_HISTORY_ITEMS}
      ''');

    final ImportableProductList history = <String>[];

    for (final Map<String, Object?> res in list) {
      final String? barcode = res['BARCODE'] as String?;
      if (barcode != null) {
        history.add(barcode);
      }
    }
    return history;
  }

  static Future<ImportableUserLists> _listUserLists(Database database) async {
    final List<Map<String, Object?>> list = await database.rawQuery('''
        SELECT _id, listName 
        FROM PRODUCT_LISTS
        ''');

    final ImportableUserLists lists = <ImportableUserList>{};

    for (final Map<String, Object?> listItem in list) {
      final int? listId = listItem['_id'] as int?;
      final String? listName = listItem['listName'] as String?;

      if (listId != null && listName != null) {
        lists.add(
          ImportableUserList(
            label: listName,
            products: await _listProducts(database, listId),
          ),
        );
      }
    }
    return lists;
  }

  static Future<List<String>> _listProducts(
    Database database,
    int listId,
  ) async {
    final List<Map<String, Object?>> list = await database.rawQuery('''
        SELECT listId, barcode 
        FROM YOUR_LISTED_PRODUCT 
        WHERE listId = $listId
        ''');

    final List<String> barcodes = <String>[];

    for (final Map<String, Object?> res in list) {
      final String? barcode = res['barcode'] as String?;
      if (barcode != null) {
        barcodes.add(barcode);
      }
    }

    return barcodes;
  }

  static Future<bool> removeDatabase() {
    return _getDatabasePath().then((String path) async {
      final File file = File(path);

      if (file.existsSync()) {
        await file.delete();
      }

      return true;
    }).onError((Object? error, StackTrace stackTrace) => false);
  }
}
