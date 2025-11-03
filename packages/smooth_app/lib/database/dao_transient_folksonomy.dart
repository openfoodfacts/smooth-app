import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';

class FolksonomyOperation {
  FolksonomyOperation({required this.type, required this.tag});

  final FolksonomyAction type;
  final ProductTag tag;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.name,
    'tag': tag.toJson(),
  };

  static FolksonomyOperation fromJson(Map<String, dynamic> json) =>
      FolksonomyOperation(
        type: FolksonomyAction.values.byName(json['type'] as String),
        tag: ProductTag.fromJson(json['tag'] as Map<String, dynamic>),
      );
}

class TransientFolksonomy {
  const TransientFolksonomy(this.barcode, this.operations);

  final String barcode;
  final String operations;
}

class _FolksonomyOperationAdapter
    extends TypeAdapter<List<FolksonomyOperation>> {
  @override
  final int typeId = 3;

  @override
  List<FolksonomyOperation> read(BinaryReader reader) =>
      _getFolksonomyOperationsFromJson(reader.toString());

  @override
  void write(BinaryWriter writer, List<FolksonomyOperation> obj) =>
      writer.writeString(_writeFolksonomyOperationsToJson(obj));
}

class DaoTransientFolksonomy extends AbstractDao {
  DaoTransientFolksonomy(super.localDatabase);

  static const String _hiveBoxName = 'transientFolksonomyOperations';

  @override
  Future<void> init() async => Hive.openBox<String>(_hiveBoxName);

  @override
  void registerAdapter() => Hive.registerAdapter(_FolksonomyOperationAdapter());

  Box<String> _getBox() => Hive.box<String>(_hiveBoxName);

  List<FolksonomyOperation> get(final String key) =>
      _getFolksonomyOperationsFromJson(_getBox().get(key) ?? '[]');

  List<String> getAllBarcodes() =>
      _getBox().keys.map((dynamic key) => key.toString()).toList();

  Future<void> put(final String key, final List<FolksonomyOperation> value) =>
      _getBox().put(key, _writeFolksonomyOperationsToJson(value));

  Future<void> delete(final String key) async => _getBox().delete(key);

  List<FolksonomyOperation> _getFolksonomyOperationsFromJson(
    final String operations,
  ) => (jsonDecode(operations) as List<dynamic>)
      .map(
        (dynamic json) =>
            FolksonomyOperation.fromJson(json as Map<String, dynamic>),
      )
      .toList();

  String _writeFolksonomyOperationsToJson(
    final List<FolksonomyOperation> operations,
  ) => jsonEncode(
    operations
        .map((FolksonomyOperation operation) => operation.toJson())
        .toList(),
  );
}

List<FolksonomyOperation> _getFolksonomyOperationsFromJson(
  final String operations,
) => (jsonDecode(operations) as List<dynamic>)
    .map(
      (dynamic json) =>
          FolksonomyOperation.fromJson(json as Map<String, dynamic>),
    )
    .toList();

String _writeFolksonomyOperationsToJson(
  final List<FolksonomyOperation> operations,
) => jsonEncode(
  operations
      .map((FolksonomyOperation operation) => operation.toJson())
      .toList(),
);
