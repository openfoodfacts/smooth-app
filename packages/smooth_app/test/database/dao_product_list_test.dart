import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_provider.dart';
import 'package:smooth_app/database/dao_product_list.dart';

import '../tests_utils/local_database_mock.dart';

class _LocalDatabase extends MockLocalDatabase {
  @override
  late final UpToDateProductListProvider upToDateProductList =
      UpToDateProductListProvider(this);
}

void main() {
  late Directory directory;
  late DaoProductList dao;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('product_lists_test_');
    Hive.init(directory.path);
    dao = DaoProductList(_LocalDatabase());
    dao.registerAdapter();
    await dao.init();
  });

  tearDown(() async {
    await Hive.close();
    Hive.resetAdapters();
    await directory.delete(recursive: true);
  });

  Future<void> populateLists() async {
    final ProductList groceries = ProductList.user('Groceries');
    groceries.set(<String>['123', '456']);
    await dao.put(groceries);
    final ProductList other = ProductList.user('Café :: snacks');
    other.set(<String>['123']);
    await dao.put(other);
    await dao.put(ProductList.user('Empty'));
    await dao.put(ProductList.history());

    // Reproduce the truncated search key from #7788 alongside valid lists.
    await Hive.close();
    final LazyBox<dynamic> box = await Hive.openLazyBox<dynamic>(
      'barcodeLists',
    );
    final dynamic storedList = await box.get(DaoProductList.getKey(groceries));
    for (final dynamic key in <dynamic>[
      'http/searc',
      'unknown::aWdub3JlZA==',
      'user_backup::aWdub3JlZA==',
      42,
    ]) {
      await box.put(key, storedList);
    }
    await box.close();
    await dao.init();
  }

  test('lists user lists without parsing unrelated database keys', () async {
    await populateLists();

    expect(
      dao.getUserLists(),
      unorderedEquals(<String>['Groceries', 'Café :: snacks', 'Empty']),
    );
  });

  test(
    'filters user lists by all requested barcodes despite unrelated keys',
    () async {
      await populateLists();

      expect(
        await dao.getUserListsWithBarcodes(<String>['123']),
        unorderedEquals(<String>['Groceries', 'Café :: snacks']),
      );
      expect(
        await dao.getUserListsWithBarcodes(<String>['123', '456']),
        <String>['Groceries'],
      );
      expect(await dao.getUserListsWithBarcodes(<String>['789']), isEmpty);
    },
  );
}
