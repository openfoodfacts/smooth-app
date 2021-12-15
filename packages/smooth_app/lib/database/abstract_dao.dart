import 'package:smooth_app/database/local_database.dart';

/// DAO abstraction
abstract class AbstractDao {
  AbstractDao(this.localDatabase);

  final LocalDatabase localDatabase;

  /// Where the specific `registerAdapter` hive related method is called.
  ///
  /// Must be called before all hive box openings.
  /// May be empty for types already taken into account, e.g. StringList
  void registerAdapter();

  /// Best place to open a hive box.
  Future<void> init();
}
