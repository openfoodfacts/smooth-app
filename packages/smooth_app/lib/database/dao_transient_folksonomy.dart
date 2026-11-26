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

  List<FolksonomyOperation>? get(String barcode) {
    final String? value = _getBox().get(barcode);
    if (value == null) {
      return null;
    }
    return _getFolksonomyOperationsFromJson(value);
  }

  Future<void> put(
    String barcode,
    List<FolksonomyOperation> operations,
  ) => _getBox().put(barcode, _writeFolksonomyOperationsToJson(operations));

  Future<void> delete(String barcode) async => _getBox().delete(barcode);

  List<FolksonomyOperation> _getFolksonomyOperationsFromJson(
    String operations,
  ) => (jsonDecode(operations) as List<dynamic>)
      .map(
        (dynamic json) =>
            FolksonomyOperation.fromJson(json as Map<String, dynamic>),
      )
      .toList();

  String _writeFolksonomyOperationsToJson(
    List<FolksonomyOperation> operations,
  ) => jsonEncode(
    operations
        .map((FolksonomyOperation operation) => operation.toJson())
        .toList(),
  );
}
