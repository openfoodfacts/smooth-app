import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';

/// "Total size" fake value for lists that are not partial/paged.
const int _uselessTotalSizeValue = 0;

/// An immutable barcode list; e.g. my search yesterday about "Nutella"
class _BarcodeList {
  const _BarcodeList(this.timestamp, this.barcodes, this.totalSize);

  _BarcodeList.now(final List<String> barcodes)
    : this(LocalDatabase.nowInMillis(), barcodes, _uselessTotalSizeValue);

  _BarcodeList.fromProductList(final ProductList productList)
    : this(
        LocalDatabase.nowInMillis(),
        productList.barcodes,
        productList.totalSize,
      );

  /// Freshness indicator: last time the list was updated.
  ///
  /// In milliseconds since epoch.
  /// Can be used to decide if the data is recent enough or deprecated.
  final int timestamp;
  final List<String> barcodes;

  /// Total size of server query results (or 0).
  final int totalSize;
}

/// Hive type adapter for [_BarcodeList]
class _BarcodeListAdapter extends TypeAdapter<_BarcodeList> {
  @override
  final int typeId = 0;

  @override
  _BarcodeList read(BinaryReader reader) {
    final int timestamp = reader.readInt();
    final List<String> barcodes = reader.readStringList();
    late int totalSize;
    try {
      totalSize = reader.readInt();
    } catch (e) {
      totalSize = _uselessTotalSizeValue;
    }
    return _BarcodeList(timestamp, barcodes, totalSize);
  }

  @override
  void write(BinaryWriter writer, _BarcodeList obj) {
    writer.writeInt(obj.timestamp);
    writer.writeStringList(obj.barcodes);
    writer.writeInt(obj.totalSize);
  }
}

class DaoProductList extends AbstractDao {
  DaoProductList(super.localDatabase);

  static const String _hiveBoxName = 'barcodeLists';
  static const String _keySeparator = '::';

  @override
  Future<void> init() async => Hive.openLazyBox<_BarcodeList>(_hiveBoxName);

  @override
  void registerAdapter() => Hive.registerAdapter(_BarcodeListAdapter());

  LazyBox<_BarcodeList> _getBox() => Hive.lazyBox<_BarcodeList>(_hiveBoxName);

  Future<_BarcodeList?> _get(final ProductList productList) async {
    final _BarcodeList? result = await _getBox().get(getKey(productList));
    if (result != null) {
      localDatabase.upToDateProductList.setLocalUpToDate(
        getKey(productList),
        result.barcodes,
      );
    }
    return result;
  }

  Future<int?> getTimestamp(final ProductList productList) async =>
      (await _get(productList))?.timestamp;

  // Why the "base64" part? Because of #753!
  // "HiveError: String keys need to be ASCII Strings with a max length of 255"
  // Encoding the parameter part in base64 makes us safe regarding ASCII.
  // As it's a list of keywords, there's a fairly high probability
  // that we'll be under the 255 character length.
  static String getKey(final ProductList productList) =>
      '${productList.listType.key}'
      '$_keySeparator'
      '${base64.encode(utf8.encode(productList.getParametersKey()))}';

  static String getProductListParameters(final String key) {
    final int pos = key.indexOf(_keySeparator);
    if (pos < 0) {
      throw Exception('Unknown key format without "$_keySeparator": $key');
    }
    if (pos + _keySeparator.length == key.length) {
      return '';
    }
    final String tmp = key.substring(pos + _keySeparator.length);
    return utf8.decode(base64.decode(tmp));
  }

  static ProductListType getProductListType(final String key) {
    final int pos = key.indexOf(_keySeparator);
    if (pos < 0) {
      throw Exception('Unknown key format without "$_keySeparator": $key');
    }
    final String value = key.substring(0, pos);
    for (final ProductListType productListType in ProductListType.values) {
      if (productListType.key == value) {
        return productListType;
      }
    }
    throw Exception('Unknown product list type: "$value" from "$key"');
  }

  Future<void> _put(final String key, final _BarcodeList barcodeList) async {
    await _getBox().put(key, barcodeList);
    localDatabase.upToDateProductList.setLocalUpToDate(
      key,
      barcodeList.barcodes,
    );
  }

  Future<void> put(final ProductList productList) async =>
      _put(getKey(productList), _BarcodeList.fromProductList(productList));

  Future<bool> delete(final ProductList productList) async {
    final LazyBox<_BarcodeList> box = _getBox();
    final String key = getKey(productList);
    localDatabase.upToDateProductList.setLocalUpToDate(key, <String>[]);
    if (!box.containsKey(key)) {
      return false;
    }
    await box.delete(key);
    return true;
  }

  /// Loads the barcode list.
  Future<void> get(final ProductList productList) async {
    final _BarcodeList? list = await _get(productList);
    final List<String> barcodes = <String>[];
    productList.totalSize = list?.totalSize ?? 0;
    if (list == null || list.barcodes.isEmpty) {
      productList.set(barcodes);
      return;
    }
    productList.set(list.barcodes);
  }

  /// Checks if a list exists in the database.
  bool exist(final ProductList productList) =>
      _getBox().containsKey(getKey(productList));

  /// Returns the number of barcodes quickly but without product check.
  Future<int> getLength(final ProductList productList) async {
    final _BarcodeList? list = await _get(productList);
    if (list == null || list.barcodes.isEmpty) {
      return 0;
    }
    return list.barcodes.length;
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
      barcodes = _getSafeBarcodeListCopy(list.barcodes);
    }
    barcodes.remove(barcode); // removes a potential duplicate
    barcodes.add(barcode);
    final _BarcodeList newList = _BarcodeList.now(barcodes);
    await _put(getKey(productList), newList);
  }

  Future<void> clear(final ProductList productList) async {
    final _BarcodeList newList = _BarcodeList.now(<String>[]);
    await _put(getKey(productList), newList);
  }

  /// Adds or removes a barcode within a product list (depending on [include])
  ///
  /// Returns true if there was a change in the list.
  Future<bool> set(
    final ProductList productList,
    final String barcode,
    final bool include,
  ) async {
    final _BarcodeList? list = await _get(productList);
    final List<String> barcodes;
    if (list == null) {
      barcodes = <String>[];
    } else {
      barcodes = _getSafeBarcodeListCopy(list.barcodes);
    }
    if (barcodes.contains(barcode)) {
      if (include) {
        return false;
      }
      barcodes.remove(barcode);
    } else {
      if (!include) {
        return false;
      }
      barcodes.add(barcode);
    }
    final _BarcodeList newList = _BarcodeList.now(barcodes);
    await _put(getKey(productList), newList);
    return true;
  }

  /// Adds or removes list of barcodes to/from a [productList] in one go (depending on [include])
  Future<void> bulkSet(
    final ProductList productList,
    final List<String> barcodes, {
    final bool include = true,
  }) async {
    final _BarcodeList? list = await _get(productList);
    final List<String> allBarcodes;

    if (list == null) {
      allBarcodes = <String>[];
    } else {
      allBarcodes = _getSafeBarcodeListCopy(list.barcodes);
    }

    for (final String barcode in barcodes) {
      if (include) {
        if (!allBarcodes.contains(barcode)) {
          allBarcodes.add(barcode);
        }
      } else {
        if (allBarcodes.contains(barcode)) {
          allBarcodes.remove(barcode);
        }
      }
    }

    final _BarcodeList newList = _BarcodeList.now(allBarcodes);
    await _put(getKey(productList), newList);
  }

  Future<ProductList> rename(
    final ProductList initialList,
    final String newName,
  ) async {
    final ProductList newList = ProductList.user(newName);
    final _BarcodeList list =
        await _get(initialList) ?? _BarcodeList.now(<String>[]);
    await _put(getKey(newList), list);
    await delete(initialList);
    await get(newList);
    return newList;
  }

  /// Exports a list - typically for debug purposes
  Future<Map<String, dynamic>> export(final ProductList productList) async {
    final Map<String, dynamic> result = <String, dynamic>{};
    final _BarcodeList? list = await _get(productList);
    if (list == null) {
      return result;
    }
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    for (final String barcode in list.barcodes) {
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

  /// Returns the names of the user lists.
  List<String> getUserLists() {
    final List<String> result = <String>[];
    for (final dynamic key in _getBox().keys) {
      final String tmp = key.toString();
      final ProductListType productListType = getProductListType(tmp);
      if (productListType != ProductListType.USER) {
        continue;
      }
      result.add(getProductListParameters(tmp));
    }
    return result;
  }

  /// Returns the names of the user lists that contains ALL the given barcodes.
  Future<List<String>> getUserListsWithBarcodes(
    final List<String> withBarcodes,
  ) async {
    final List<String> result = <String>[];
    for (final dynamic key in _getBox().keys) {
      final String tmp = key.toString();
      final ProductListType productListType = getProductListType(tmp);
      if (productListType != ProductListType.USER) {
        continue;
      }
      final _BarcodeList? barcodeList = await _getBox().get(key);
      if (barcodeList == null) {
        continue;
      }
      for (final String barcode in withBarcodes) {
        if (!barcodeList.barcodes.contains(barcode)) {
          break;
        }
        if (withBarcodes.last == barcode) {
          result.add(getProductListParameters(tmp));
          break;
        }
      }
    }
    return result;
  }

  /// Returns a write-safe copy of [_BarcodeList] barcodes.
  ///
  /// cf. https://github.com/openfoodfacts/smooth-app/issues/1786
  /// As we're using hive, all the data are loaded at init time. And not
  /// systematically refreshed at each [get] call.
  /// Therefore, when we need a barcode list from [_BarcodeList] with the intent
  /// to add/remove a barcode to/from that list, we can avoid concurrency issues
  /// by copying the barcode list instead of reusing it.
  /// Example:
  /// BAD
  /// ```dart
  /// List<String> barcodes = _barcodeList.barcodes;
  /// barcodes.add('1234'); // dangerous if somewhere else we parse the list
  /// ```
  /// GOOD
  /// ```dart
  /// List<String> barcodes = _getSafeBarcodeListCopy(_barcodeList.barcodes);
  /// barcodes.add('1234'); // no risk at all
  /// ```
  static List<String> _getSafeBarcodeListCopy(final List<String> barcodes) =>
      List<String>.from(barcodes);
}
