import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';

class FolksonomyOperationValue {
  FolksonomyOperationValue({required this.type, required this.tag});

  final FolksonomyAction type;
  final ProductTag tag;

  @override
  String toString() => 'FolksonomyOperationValue($type, $tag)';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.name,
    'tag': tag.toJson(),
  };
  static FolksonomyOperationValue fromJson(Map<String, dynamic> json) =>
      FolksonomyOperationValue(
        type: FolksonomyAction.values.byName(json['type'] as String),
        tag: ProductTag.fromJson(json['tag'] as Map<String, dynamic>),
      );
}

class TransientFolksonomyOperation {
  const TransientFolksonomyOperation(this.key, this.value);

  final String key;
  final FolksonomyOperationValue value;
}

class _FolksonomyOperationValueAdapter
    extends TypeAdapter<FolksonomyOperationValue> {
  @override
  final int typeId = 3;

  @override
  FolksonomyOperationValue read(BinaryReader reader) =>
      FolksonomyOperationValue.fromJson(
        jsonDecode(reader.readString()) as Map<String, dynamic>,
      );

  @override
  void write(BinaryWriter writer, FolksonomyOperationValue obj) =>
      writer.writeString(jsonEncode(obj.toJson()));
}

class DaoTransientFolksonomyOperation extends AbstractDao {
  DaoTransientFolksonomyOperation(super.localDatabase);

  static const String _hiveBoxName = 'transientFolksonomyOperations';

  @override
  Future<void> init() async =>
      Hive.openBox<FolksonomyOperationValue>(_hiveBoxName);

  @override
  void registerAdapter() =>
      Hive.registerAdapter(_FolksonomyOperationValueAdapter());

  Box<FolksonomyOperationValue> _getBox() =>
      Hive.box<FolksonomyOperationValue>(_hiveBoxName);

  FolksonomyOperationValue? get(final String key) => _getBox().get(key);

  Future<void> put(final String key, final FolksonomyOperationValue value) =>
      _getBox().put(key, value);

  Future<void> delete(final String key) async => _getBox().delete(key);

  Future<String> getNewKey(OperationType type, String barcode) async {
    return type.getNewKey(localDatabase, barcode: barcode);
  }

  Iterable<TransientFolksonomyOperation> getAll(final String barcode) {
    final Box<FolksonomyOperationValue> box = _getBox();
    final List<TransientFolksonomyOperation> result =
        <TransientFolksonomyOperation>[];
    for (final dynamic key in box.keys) {
      final FolksonomyOperationValue? value = box.get(key);
      if (value == null) {
        continue;
      }
      final ProductTag productTag = value.tag;
      if (productTag.barcode != barcode) {
        continue;
      }
      result.add(TransientFolksonomyOperation(key.toString(), value));
    }
    return result;
  }
}
