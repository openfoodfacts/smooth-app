import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/dao_product_migration.dart';
import 'package:smooth_app/database/local_database.dart';

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

// TODO(monsieurtanuki): remove when old enough (today is 2022-06-16)
/// Where we store the products as "barcode => product".
@Deprecated('use [DaoProduct] instead')
class DaoHiveProduct extends AbstractDao implements DaoProductMigrationSource {
  @Deprecated('use [DaoProduct] instead')
  DaoHiveProduct(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'products';

  @override
  Future<void> init() async => Hive.openLazyBox<Product>(_hiveBoxName);

  @override
  void registerAdapter() => Hive.registerAdapter(_ProductAdapter());

  LazyBox<Product> _getBox() => Hive.lazyBox<Product>(_hiveBoxName);

  Future<Product?> get(final String barcode) async => _getBox().get(barcode);

  @override
  Future<Map<String, Product>> getAll(final List<String> barcodes) async {
    final LazyBox<Product> box = _getBox();
    final Map<String, Product> result = <String, Product>{};
    for (final String barcode in barcodes) {
      final Product? product = await box.get(barcode);
      if (product != null) {
        result[barcode] = product;
      }
    }
    return result;
  }

  Future<void> put(final Product product) async => putAll(<Product>[product]);

  Future<void> putAll(final Iterable<Product> products) async {
    final Map<String, Product> upserts = <String, Product>{};
    for (final Product product in products) {
      upserts[product.barcode!] = product;
    }
    await _getBox().putAll(upserts);
  }

  @override
  Future<List<String>> getAllKeys() async {
    final LazyBox<Product> box = _getBox();
    final List<String> result = <String>[];
    for (final dynamic key in box.keys) {
      result.add(key.toString());
    }
    return result;
  }

  // Just for the migration
  @override
  Future<void> deleteAll(final List<String> barcodes) async {
    final LazyBox<Product> box = _getBox();
    await box.deleteAll(barcodes);
  }
}
