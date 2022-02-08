import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/abstract_dao.dart';
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

/// Where we store the products as "barcode => product".
class DaoProduct extends AbstractDao {
  DaoProduct(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'products';

  @override
  Future<void> init() async => Hive.openLazyBox<Product>(_hiveBoxName);

  @override
  void registerAdapter() => Hive.registerAdapter(_ProductAdapter());

  LazyBox<Product> _getBox() => Hive.lazyBox<Product>(_hiveBoxName);

  Future<Product?> get(final String barcode) async => _getBox().get(barcode);

  Future<Map<String, Product>> getAll(final Iterable<String> barcodes) async {
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
}
