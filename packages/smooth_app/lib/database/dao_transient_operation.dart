import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/abstract_dao.dart';

/// Transient operation: a minimalist [product] with a [key].
///
/// The [key] has nothing to do with the barcode, it's an operation key.
/// Typically, the [key] may include:
/// * a type ("it's a detail change")
/// * a sequential id (in order to sort operations)
class TransientOperation {
  const TransientOperation(this.key, this.product);

  final String key;
  final Product product;

  @override
  String toString() => 'TransientOperation($key})';
}

/// Hive type adapter for [Product]
class _ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 2;

  @override
  Product read(BinaryReader reader) =>
      Product.fromJson(jsonDecode(reader.readString()) as Map<String, dynamic>);

  @override
  void write(BinaryWriter writer, Product obj) =>
      writer.writeString(jsonEncode(obj.toJson()));
}

/// Where we store products for transient operations.
///
/// Use [DaoProduct] instead if you want to enrich the local product database.
///
/// This class is only for transient operations.
/// For instance, when you submit a change, we store the changes here,
/// while async'ly saving them on the server. This way we can take into account
/// those changes in the app before they are actually saved on the server. And
/// typically, when we got an ACK from the server, we can remove that change
/// from the pending changes.
///
/// It is open to different uses, therefore the key is just a stupid String.
/// Of course, to make those different uses compatible, the key should be
/// properly designed, e.g. with all keys starting with `'USECASEx;'`
///
/// This is not a Lazy database, because:
/// * it's supposed to be little anyway, so we can load it at startup
/// * the way we use it may sometimes require instant access (no `await`)
class DaoTransientOperation extends AbstractDao {
  DaoTransientOperation(super.localDatabase);

  static const String _hiveBoxName = 'transientOperations';

  @override
  Future<void> init() async => Hive.openBox<Product>(_hiveBoxName);

  @override
  void registerAdapter() => Hive.registerAdapter(_ProductAdapter());

  Box<Product> _getBox() => Hive.box<Product>(_hiveBoxName);

  Product? get(final String key) => _getBox().get(key);

  Future<void> put(final String key, final Product product) =>
      _getBox().put(key, product);

  Future<void> delete(final String key) async => _getBox().delete(key);

  List<String> getAllKeys() {
    final Box<Product> box = _getBox();
    final List<String> result = <String>[];
    for (final dynamic key in box.keys) {
      result.add(key.toString());
    }
    return result;
  }

  Iterable<TransientOperation> getAll(final String barcode) {
    final Box<Product> box = _getBox();
    final List<TransientOperation> result = <TransientOperation>[];
    for (final dynamic key in box.keys) {
      final Product? product = box.get(key);
      if (product == null) {
        // very unlikely
        continue;
      }
      if (product.barcode != barcode) {
        continue;
      }
      result.add(TransientOperation(key.toString(), product));
    }
    return result;
  }
}
