import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/local_database.dart';

/// Where we store ints.
class DaoInt extends AbstractDao {
  DaoInt(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'int';

  @override
  Future<void> init() async => Hive.openBox<int>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<int> _getBox() => Hive.box<int>(_hiveBoxName);

  int? get(final String key) => _getBox().get(key);

  Future<void> put(final String key, final int? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);
}
