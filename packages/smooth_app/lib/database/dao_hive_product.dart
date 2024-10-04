import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/abstract_dao.dart';

/// Hive type adapter for [Product]
class _ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) =>
      Product.fromJson(jsonDecode(reader.readString()) as Map<String, dynamic>);

  @override
  void write(BinaryWriter writer, Product obj) =>
      writer.writeString(jsonEncode(obj.toJson()));
}

/// /!\ Stupid class not be used anymore (from 2022-06-16)
/// But Hive needs it - it doesn't like data to be removed...
/// Where we store the products as "barcode => product".
@Deprecated('use [DaoProduct] instead')
class DaoHiveProduct extends AbstractDao {
  @Deprecated('use [DaoProduct] instead')
  DaoHiveProduct(super.localDatabase);

  static const String _hiveBoxName = 'products';

  @override
  Future<void> init() async => Hive.openLazyBox<Product>(_hiveBoxName);

  @override
  void registerAdapter() => Hive.registerAdapter(_ProductAdapter());
}
