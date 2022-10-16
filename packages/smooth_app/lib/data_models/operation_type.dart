import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';

/// Type of a transient operation.
enum OperationType {
  details('D');

  const OperationType(this.header);

  final String header;

  static const String _transientHeaderSeparator = ';';

  String getNewKey(
    final LocalDatabase localDatabase,
    final String barcode,
  ) {
    final int id = localDatabase.getLocalUniqueSequenceNumber();
    return '$header'
        '$_transientHeaderSeparator$id'
        '$_transientHeaderSeparator$barcode';
  }

  bool matches(final TransientOperation action) =>
      action.key.startsWith('$header$_transientHeaderSeparator');

  static int sort(String a, String b) {
    final List<String> keyA = a.split(_transientHeaderSeparator);
    final List<String> keyB = b.split(_transientHeaderSeparator);
    return int.parse(keyA[1]).compareTo(int.parse(keyB[1]));
  }
}
