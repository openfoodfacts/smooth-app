import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/local_database.dart';

/// Where we store string lists
class DaoStringList extends AbstractDao {
  DaoStringList(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'stringList';

  // for the moment we use only one string list
  static const String _key = 'searchHistory';
  static const int _max = 10;

  @override
  Future<void> init() async => Hive.openBox<List<String>>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<List<String>> _getBox() => Hive.box<List<String>>(_hiveBoxName);

  Future<List<String>> getAll() async =>
      _getBox().get(_key, defaultValue: <String>[])!;

  Future<void> add(final String string) async {
    final List<String> value = await getAll();
    value.remove(string);
    value.add(string);
    while (value.length > _max) {
      value.removeAt(0);
    }
    await _getBox().put(_key, value);
    localDatabase.notifyListeners();
  }

  Future<bool> remove(final String string) async {
    final List<String> value = await getAll();
    if (value.remove(string)) {
      await _getBox().put(_key, value);
      localDatabase.notifyListeners();
      return true;
    }
    return false;
  }
}
