import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/dao_string_list.dart';

class LocalDatabase extends ChangeNotifier {
  LocalDatabase._();

  /// Notify listeners
  /// Comments added only in order to avoid a "warning"
  /// For the record, we need to override the method
  /// because the parent's is protected
  @override
  void notifyListeners() => super.notifyListeners();

  static Future<LocalDatabase> getLocalDatabase() async {
    await Hive.initFlutter();
    final LocalDatabase localDatabase = LocalDatabase._();
    final List<AbstractDao> daos = <AbstractDao>[
      DaoProduct(localDatabase),
      DaoProductList(localDatabase),
      DaoStringList(localDatabase),
    ];
    for (final AbstractDao dao in daos) {
      dao.registerAdapter();
    }
    for (final AbstractDao dao in daos) {
      await dao.init();
    }
    return localDatabase;
  }

  static int nowInMillis() => DateTime.now().millisecondsSinceEpoch;
}
