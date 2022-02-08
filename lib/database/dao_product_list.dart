import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';

/// An immutable barcode list; e.g. my search yesterday about "Nutella"
class _BarcodeList {
  _BarcodeList(this.timestamp, this.barcodes);

  _BarcodeList.now(final List<String> barcodes)
      : this(LocalDatabase.nowInMillis(), barcodes);

  _BarcodeList.fromProductList(final ProductList productList)
      : this(LocalDatabase.nowInMillis(), productList.barcodes);

  /// Freshness indicator: last time the list was updated.
  ///
  /// In milliseconds since epoch.
  /// Can be used to decide if the data is recent enough or deprecated.
  final int timestamp;
  final List<String> barcodes;
}

/// Hive type adapter for [_BarcodeList]
class _BarcodeListAdapter extends TypeAdapter<_BarcodeList> {
  @override
  final int typeId = 0;

  @override
  _BarcodeList read(BinaryReader reader) {
    final int timestamp = reader.readInt();
    final List<String> barcodes = reader.readStringList();
    return _BarcodeList(timestamp, barcodes);
  }

  @override
  void write(BinaryWriter writer, _BarcodeList obj) {
    writer.writeInt(obj.timestamp);
    writer.writeStringList(obj.barcodes);
  }
}

class DaoProductList extends AbstractDao {
  DaoProductList(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'barcodeLists';

  @override
  Future<void> init() async => Hive.openBox<_BarcodeList>(_hiveBoxName);

  @override
  void registerAdapter() => Hive.registerAdapter(_BarcodeListAdapter());

  Box<_BarcodeList> _getBox() => Hive.box<_BarcodeList>(_hiveBoxName);

  Future<_BarcodeList?> _get(final ProductList productList) async =>
      _getBox().get(_getKey(productList));

  Future<int?> getTimestamp(final ProductList productList) async =>
      (await _get(productList))?.timestamp;

  // Why the "base64" part? Because of #753!
  // "HiveError: String keys need to be ASCII Strings with a max length of 255"
  // Encoding the parameter part in base64 makes us safe regarding ASCII.
  // As it's a list of keywords, there's a fairly high probability
  // that we'll be under the 255 character length.
  String _getKey(final ProductList productList) => '${productList.listType.key}'
      '::'
      '${base64.encode(utf8.encode(productList.parameters))}';

  Future<void> _put(final String key, final _BarcodeList barcodeList) async =>
      _getBox().put(key, barcodeList);

  Future<void> put(final ProductList productList) async =>
      _put(_getKey(productList), _BarcodeList.fromProductList(productList));

  Future<void> delete(final String key) async => _getBox().delete(key);

  /// Loads the barcodes AND all the products.
  Future<void> get(final ProductList productList) async {
    final _BarcodeList? list = await _get(productList);
    final List<String> barcodes = <String>[];
    final Map<String, Product> products = <String, Product>{};
    if (list == null || list.barcodes.isEmpty) {
      productList.set(barcodes, products);
      return;
    }
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    for (final String barcode in list.barcodes) {
      try {
        final Product? product = await daoProduct.get(barcode);
        if (product != null) {
          barcodes.add(barcode);
          products[barcode] = product;
        } else {
          debugPrint('unexpected: unknown product for $barcode');
        }
      } catch (e) {
        debugPrint('unexpected: exception for product $barcode');
      }
    }
    productList.set(barcodes, products);
  }

  /// Moves a barcode to the end of the list.
  ///
  /// One barcode duplicate is potentially removed:
  /// * If the barcode was already there, it's moved to the end of the list.
  /// * If the barcode wasn't there, it's added to the end of the list.
  Future<void> push(final ProductList productList, final String barcode) async {
    final _BarcodeList? list = await _get(productList);
    final List<String> barcodes;
    if (list == null) {
      barcodes = <String>[];
    } else {
      barcodes = list.barcodes;
    }
    barcodes.remove(barcode); // removes a potential duplicate
    barcodes.add(barcode);
    final _BarcodeList newList = _BarcodeList.now(barcodes);
    await _put(_getKey(productList), newList);
  }

  Future<void> clear(final ProductList productList) async =>
      _getBox().delete(_getKey(productList));

  /// Exports a list - typically for debug purposes
  Future<Map<String, dynamic>> export(final ProductList productList) async {
    final Map<String, dynamic> result = <String, dynamic>{};
    final _BarcodeList? list = await _get(productList);
    if (list == null) {
      return result;
    }
    final List<String> barcodes = list.barcodes;
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    for (final String barcode in barcodes) {
      late bool? present;
      try {
        final Product? product = await daoProduct.get(barcode);
        present = product != null;
      } catch (e) {
        present = null;
      }
      result[barcode] = present;
    }
    return result;
  }
}
