import 'package:smooth_app/database/local_database.dart';

/// DAO abstraction
abstract class AbstractDao {
  AbstractDao(this.localDatabase);

  final LocalDatabase localDatabase;
}
