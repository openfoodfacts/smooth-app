import 'package:smooth_app/database/bulk_manager.dart';

/// Interface for bulk database inserts.
///
/// cf. [BulkManager]
abstract class BulkInsertable {
  /// Insert columns for bulk mode
  List<String> getInsertColumns();

  /// Table name
  String getTableName();
}
