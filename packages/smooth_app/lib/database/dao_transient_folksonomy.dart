import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_operation.dart';

class DaoTransientFolksonomy extends AbstractDao {
  DaoTransientFolksonomy(super.localDatabase);

  static const String _hiveBoxName = 'transientFolksonomyOperations';

  @override
  Future<void> init() async => Hive.openBox<String>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<String> _getBox() => Hive.box<String>(_hiveBoxName);

  List<FolksonomyOperation>? get(final String barcode) {
    final String? value = _getBox().get(barcode);
    if (value == null) {
      return null;
    }
    return _getFolksonomyOperationsFromJson(value);
  }

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
