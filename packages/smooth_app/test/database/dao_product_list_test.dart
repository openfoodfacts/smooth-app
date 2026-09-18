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

  test('restores the API barcode stored with a scan session', () async {
    const String barcode = '4260392550101';
    const String apiBarcode = '010426039255010117270101';
    final ProductList scanSession = ProductList.scanSession();

    await daoProductList.push(scanSession, barcode, apiBarcode: apiBarcode);

    final ProductList restoredScanSession = ProductList.scanSession();
    await daoProductList.get(restoredScanSession);

    expect(restoredScanSession.barcodes, <String>[barcode]);
    expect(restoredScanSession.getApiBarcode(barcode), apiBarcode);
  });

  test('removes a stored API barcode with its normalized barcode', () async {
    const String barcode = '4260392550101';
    final ProductList scanSession = ProductList.scanSession();
    await daoProductList.push(
      scanSession,
      barcode,
      apiBarcode: '010426039255010117270101',
    );

    await daoProductList.set(scanSession, barcode, false);

    final ProductList restoredScanSession = ProductList.scanSession();
    await daoProductList.get(restoredScanSession);
    expect(restoredScanSession.barcodes, isEmpty);
    expect(restoredScanSession.apiBarcodes, isEmpty);
  });
}
