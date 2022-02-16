import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/local_database.dart';

/// Where we store ints.
class DaoInt extends AbstractDao {
  DaoInt(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'int';

  @override
  Future<void> init() async => Hive.openLazyBox<int>(_hiveBoxName);

  @override
  void registerAdapter() {}

  LazyBox<int> _getBox() => Hive.lazyBox<int>(_hiveBoxName);

  Future<int?> get(final String key) async => _getBox().get(key);

  Future<void> put(final String key, final int? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);
}
