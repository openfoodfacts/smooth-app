import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/local_database.dart';

class DaoStringListMap extends AbstractDao {
  DaoStringListMap(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'robotoffMap';
  static const String _key = 'votedHistory';

  @override
  Future<void> init() async =>
      Hive.openBox<Map<dynamic, dynamic>>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<Map<dynamic, dynamic>> _getBox() {
    return Hive.box<Map<dynamic, dynamic>>(_hiveBoxName);
  }

  Future<Map<String, List<String>>> getAll() async {
    final Map<String, List<String>> mapFinal = <String, List<String>>{};
    final Map<dynamic, dynamic> mapDynamic =
        _getBox().get(_key) ?? <dynamic, dynamic>{};

    for (final dynamic item in mapDynamic.keys) {
      final dynamic listTemp = mapDynamic[item];
      mapFinal[item.toString()] = List<String>.from(listTemp as List<String>);
    }
    return mapFinal;
  }

  Future<void> add(final String barcode, String insightId) async {
    final Map<String, List<String>> value = await getAll();
    if (value.keys.contains(barcode)) {
      if (value[barcode] == null) {
        value[barcode] = <String>[insightId];
      } else {
        if (!value[barcode]!.contains(insightId)) {
          value[barcode]!.add(insightId);
        }
      }
    } else {
      value.putIfAbsent(barcode, () => <String>[insightId]);
    }
    await _getBox().put(_key, value);
    localDatabase.notifyListeners();
  }

  Future<bool> removeKey(final String barcode) async {
    final Map<String, List<String>> value = await getAll();
    if (value.remove(barcode) != null) {
      await _getBox().put(_key, value);
      localDatabase.notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> removeStringValue(final String insightId) async {
    final Map<String, List<String>> value = await getAll();
    bool needNotify = false;
    for (final String barcode in value.keys) {
      final List<String> insights = value[barcode] ?? <String>[];
      if (insights.contains(insightId)) {
        value[barcode]!.remove(insightId);
        needNotify = true;
        break;
      }
    }
    if (needNotify) {
      await _getBox().put(_key, value);
      localDatabase.notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> containsStringValue(final String insightId) async {
    final Map<String, List<String>> value = await getAll();
    bool exists = false;
    for (final String barcode in value.keys) {
      final List<String> insights = value[barcode] ?? <String>[];
      if (insights.contains(insightId)) {
        exists = true;
        break;
      }
    }
    return exists;
  }
}
