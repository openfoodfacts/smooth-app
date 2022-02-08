import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/local_database.dart';

/// Where we store strings.
///
/// Typical use case: large strings used for onboarding.
/// That's why we use lazy boxes, and not boxes, and not sharedpreferences:
/// we're talking about large data (several 10Kb) that we almost never need,
/// and that should not make the app boot slower.
class DaoString extends AbstractDao {
  DaoString(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'string';

  @override
  Future<void> init() async => Hive.openLazyBox<String>(_hiveBoxName);

  @override
  void registerAdapter() {}

  LazyBox<String> _getBox() => Hive.lazyBox<String>(_hiveBoxName);

  Future<String?> get(final String key) async => _getBox().get(key);

  Future<void> put(final String key, final String? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);
}
