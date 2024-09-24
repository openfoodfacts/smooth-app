import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';

/// Where we store strings that need INSTANT access (= not lazy, no await).
class DaoInstantString extends AbstractDao {
  DaoInstantString(super.localDatabase);

  static const String _hiveBoxName = 'instantString';

  @override
  Future<void> init() async => Hive.openBox<String>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<String> _getBox() => Hive.box<String>(_hiveBoxName);

  String? get(final String key) => _getBox().get(key);

  Future<void> put(final String key, final String? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);
}
