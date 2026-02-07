import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';

/// Where we store ints.
class DaoInt extends AbstractDao {
  DaoInt(super.localDatabase);

  static const String _hiveBoxName = 'int';

  @override
  Future<void> init() async => Hive.openBox<int>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<int> _getBox() => Hive.box<int>(_hiveBoxName);

  int? get(final String key) => _getBox().get(key);

  Future<void> put(final String key, final int? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);

  /// Returns a progressive number each time it is invoked for a given [key].
  /// This is useful to generate a unique id for a given [key].
  ///
  /// The [key] is a string that is used to identify the sequence.
  ///
  /// The progressive number is saved in the database, so that it is persistent.
  Future<int> getNextSequenceNumber(final String key) async {
    int? result = get(key);
    if (result == null) {
      result = 1;
    } else {
      result++;
    }
    await put(key, result);
    return result;
  }
}
