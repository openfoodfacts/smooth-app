import 'package:smooth_app/database/local_database.dart';

/// DAO abstraction for SQL.
abstract class AbstractSqlDao {
  AbstractSqlDao(this.localDatabase);

  final LocalDatabase localDatabase;
}
