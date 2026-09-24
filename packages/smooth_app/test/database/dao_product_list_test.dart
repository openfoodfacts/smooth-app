import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';

void main() {
  group('DaoProductList key parsing', () {
    test('valid user product list key', () {
      final ProductList productList = ProductList.user('My favorites');
      final String key = DaoProductList.getKey(productList);

      expect(DaoProductList.getProductListType(key), ProductListType.USER);
      expect(DaoProductList.getProductListParameters(key), 'My favorites');
    });

    test('valid scan history key', () {
      final ProductList productList = ProductList.scanHistory();
      final String key = DaoProductList.getKey(productList);

      expect(
        DaoProductList.getProductListType(key),
        ProductListType.SCAN_HISTORY,
      );
      expect(DaoProductList.getProductListParameters(key), '');
    });

    test('keys without "::" separator do not throw and return null', () {
      const List<String> invalidKeys = <String>[
        'http/searc',
        'http/search/keywords',
        'history',
        'user',
        '',
        'random_string_without_separator',
      ];

      for (final String key in invalidKeys) {
        expect(
          DaoProductList.getProductListType(key),
          isNull,
          reason: 'Key "$key" should return null for product list type',
        );
        expect(
          DaoProductList.getProductListParameters(key),
          isNull,
          reason: 'Key "$key" should return null for product list parameters',
        );
      }
    });

    test('keys with unknown product list type return null', () {
      final String encoded = base64.encode(utf8.encode('test'));
      final String key = 'unknown_type::$encoded';

      expect(DaoProductList.getProductListType(key), isNull);
      expect(DaoProductList.getProductListParameters(key), 'test');
    });

    test(
      'keys with invalid base64 parameters return null without throwing',
      () {
        const String key = 'user::!@#not_valid_base64#@!';

        expect(DaoProductList.getProductListType(key), ProductListType.USER);
        expect(DaoProductList.getProductListParameters(key), isNull);
      },
    );

    test('empty parameter part after separator returns empty string', () {
      const String key = 'user::';

      expect(DaoProductList.getProductListType(key), ProductListType.USER);
      expect(DaoProductList.getProductListParameters(key), '');
    });
  });
}
