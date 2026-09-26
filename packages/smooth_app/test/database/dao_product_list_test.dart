import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_provider.dart';
import 'package:smooth_app/database/dao_product_list.dart';

import '../tests_utils/local_database_mock.dart';

class _TestLocalDatabase extends MockLocalDatabase {
  late final UpToDateProductListProvider _upToDateProductList =
      UpToDateProductListProvider(this);

  @override
  UpToDateProductListProvider get upToDateProductList => _upToDateProductList;
}

void main() {
  late Directory hiveDirectory;
  late DaoProductList daoProductList;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'dao_product_list_test',
    );
    Hive.init(hiveDirectory.path);
    daoProductList = DaoProductList(_TestLocalDatabase());
    daoProductList.registerAdapter();
    await daoProductList.init();
  });

  tearDown(() async {
    await daoProductList.clear(ProductList.scanSession());
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('persists barcodes of a scan session', () async {
    const String barcode = '4260392550101';
    final ProductList scanSession = ProductList.scanSession();

    await daoProductList.push(scanSession, barcode);

    final ProductList restoredScanSession = ProductList.scanSession();
    await daoProductList.get(restoredScanSession);

    expect(restoredScanSession.barcodes, <String>[barcode]);
  });

  test('removes a barcode from a scan session', () async {
    const String barcode = '4260392550101';
    final ProductList scanSession = ProductList.scanSession();
    await daoProductList.push(scanSession, barcode);

    await daoProductList.set(scanSession, barcode, false);

    final ProductList restoredScanSession = ProductList.scanSession();
    await daoProductList.get(restoredScanSession);
    expect(restoredScanSession.barcodes, isEmpty);
  });
}
