import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/data_models/product_list.dart';
import '../../tests_utils/local_database_mock.dart';
import 'package:smooth_app/pages/product/common/product_list_helper.dart';

void main() {
  group('ProductListHelper.isBarcodeValid', () {
    test('validates 8-digit EAN-8 barcodes', () {
      expect(ProductListHelper.isBarcodeValid('12345678'), isTrue);
      expect(ProductListHelper.isBarcodeValid('96385074'), isTrue);
    });

    test('validates 12-digit UPC-A barcodes', () {
      expect(ProductListHelper.isBarcodeValid('012345678905'), isTrue);
      expect(ProductListHelper.isBarcodeValid('123456789012'), isTrue);
    });

    test('validates 13-digit EAN-13 barcodes', () {
      expect(ProductListHelper.isBarcodeValid('1234567890123'), isTrue);
      expect(ProductListHelper.isBarcodeValid('3017620422003'), isTrue);
    });

    test('validates 14-digit GTIN-14 barcodes', () {
      expect(ProductListHelper.isBarcodeValid('12345678901234'), isTrue);
      expect(ProductListHelper.isBarcodeValid('00012345678905'), isTrue);
    });

    test('rejects numeric strings with non-standard lengths', () {
      expect(ProductListHelper.isBarcodeValid(''), isFalse);
      expect(ProductListHelper.isBarcodeValid('1234567'), isFalse);
      expect(ProductListHelper.isBarcodeValid('0'), isFalse);
      expect(ProductListHelper.isBarcodeValid('123456789'), isFalse);
      expect(ProductListHelper.isBarcodeValid('1234567890'), isFalse);
      expect(ProductListHelper.isBarcodeValid('12345678901'), isFalse);
      expect(ProductListHelper.isBarcodeValid('123456789012345'), isFalse);
    });

    test('rejects non-numeric strings, URLs, and bracketed GS1 codes', () {
      expect(ProductListHelper.isBarcodeValid('12345678a'), isFalse);
      expect(ProductListHelper.isBarcodeValid('not-a-barcode'), isFalse);
      expect(ProductListHelper.isBarcodeValid('1234 5678'), isFalse);
      expect(
        ProductListHelper.isBarcodeValid('(01)04044782317112(17)270101'),
        isFalse,
      );
      expect(
        ProductListHelper.isBarcodeValid('https://openfoodfacts.org'),
        isFalse,
      );
    });
  });

  group('ProductListHelper.fileToBarcodes', () {
    test('extracts valid barcodes from CSV content', () {
      final Directory tempDir = Directory.systemTemp.createTempSync();
      final File file = File('${tempDir.path}/test_barcodes.csv');
      file.writeAsStringSync(
        'Barcode;Name;Brand\n'
        '"12345678";"Product A";"Brand A"\n'
        '012345678905;Product B;Brand B\n'
        '1234567890123;Product C;Brand C\n'
        'invalid line with no separators\n',
      );

      final ProductListHelper helper = ProductListHelper(
        list: ProductList.history(),
        localDatabase: MockLocalDatabase(),
      );

      final List<String> extracted = helper.fileToBarcodes(file);

      expect(extracted, <String>[
        'Barcode',
        '12345678',
        '012345678905',
        '1234567890123',
      ]);

      tempDir.deleteSync(recursive: true);
    });
  });
}
