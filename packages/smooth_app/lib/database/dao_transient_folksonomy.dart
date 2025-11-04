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

class DaoTransientFolksonomy extends AbstractDao {
  DaoTransientFolksonomy(super.localDatabase);

  static const String _hiveBoxName = 'transientFolksonomyOperations';

  @override
  Future<void> init() async => Hive.openBox<String>(_hiveBoxName);

  @override
  void registerAdapter() {
    // We don't need it here since we encode/decode Strings.
  }

  Box<String> _getBox() => Hive.box<String>(_hiveBoxName);

  List<FolksonomyOperation> get(final String barcode) =>
      _getFolksonomyOperationsFromJson(_getBox().get(barcode) ?? '[]');

  FolksonomyOperation? getFirst(final String barcode) =>
      get(barcode).firstOrNull;

  List<String> getAllBarcodes() =>
      _getBox().keys.map((dynamic barcode) => barcode.toString()).toList();

  Future<void> put(
    final String barcode,
    final List<FolksonomyOperation> operations,
  ) => _getBox().put(barcode, _writeFolksonomyOperationsToJson(operations));

  Future<void> delete(final String barcode) async => _getBox().delete(barcode);

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
