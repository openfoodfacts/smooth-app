import 'package:smooth_app/database/bulk_insertable.dart';

/// Interface for bulk database deletes.
///
/// cf. [BulkManager], [BulkInsertable]
abstract class BulkDeletable implements BulkInsertable {
  /// "where" clause for delete in bulk mode
  String getDeleteWhere(List<dynamic> deleteWhereArgs);
}
