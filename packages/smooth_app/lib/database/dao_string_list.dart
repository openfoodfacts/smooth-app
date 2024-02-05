import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/local_database.dart';

/// Where we store string lists with unique items.
class DaoStringList extends AbstractDao {
  DaoStringList(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'stringList';

  static const String keySearchHistory = 'searchHistory';

  /// Key for the list of task ids.
  static const String keyTasks = 'tasks';

  /// Key for the list of latest languages used in the app.
  static const String keyLanguages = 'languages';

  /// Max lengths of each key (null means no limit).
  static const Map<String, int?> _maxLengths = <String, int?>{
    keySearchHistory: 10,
    keyTasks: null,
    // TODO(monsieurtanuki): more "latest" languages are possible if we create a page to remove some of them
    keyLanguages: 1,
  };

  @override
  Future<void> init() async => Hive.openBox<List<String>>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<List<String>> _getBox() => Hive.box<List<String>>(_hiveBoxName);

  List<String> getAll(final String key) =>
      _getBox().get(key, defaultValue: <String>[])!;

  /// Adds a unique value to the end. Removes is before if it pre-existed.
  Future<void> add(final String key, final String string) async {
    final List<String> value = getAll(key);
    value.remove(string);
    value.add(string);
    final int? maxLength = _maxLengths[key];
    if (maxLength != null) {
      while (value.length > maxLength) {
        value.removeAt(0);
      }
    }
    await _getBox().put(key, value);
    localDatabase.notifyListeners();
  }

  Future<bool> remove(final String key, final String item) async {
    final List<String> list = getAll(key);
    if (list.remove(item)) {
      await _getBox().put(key, list);
      localDatabase.notifyListeners();
      return true;
    }
    return false;
  }
}
