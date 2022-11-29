import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/database_helper.dart';

/// Type of a transient operation.
///
/// We need a type to discriminate between operations (cf. [getNewKey]).
/// When we are in a collection of operations, the keys will helper us know
/// * which type (cf. [matches])
/// * which order (cf. [getSequentialId], [sort])
/// * possibly, which barcode (not useful yet)
enum OperationType {
  image('I'),
  refreshLater('R'),
  details('D');

  const OperationType(this.header);

  final String header;

  static const String _transientHeaderSeparator = ';';

  static const String _uniqueSequenceKey = 'OperationType';

  Future<String> getNewKey(
    final LocalDatabase localDatabase,
    final String barcode,
  ) async {
    final int sequentialId =
        await getNextSequenceNumber(DaoInt(localDatabase), _uniqueSequenceKey);
    return '$header'
        '$_transientHeaderSeparator$sequentialId'
        '$_transientHeaderSeparator$barcode';
  }

  bool matches(final TransientOperation action) =>
      action.key.startsWith('$header$_transientHeaderSeparator');

  static int getSequentialId(final TransientOperation operation) {
    final List<String> keyItems =
        operation.key.split(_transientHeaderSeparator);
    return int.parse(keyItems[1]);
  }

  static String getBarcode(final String key) {
    final List<String> keyItems = key.split(_transientHeaderSeparator);
    return keyItems[2];
  }

  static OperationType? getOperationType(final String key) {
    final List<String> keyItems = key.split(_transientHeaderSeparator);
    final String find = keyItems[0];
    for (final OperationType operationType in OperationType.values) {
      if (operationType.header == find) {
        return operationType;
      }
    }
    return null;
  }

  static int sort(
    final TransientOperation operationA,
    final TransientOperation operationB,
  ) =>
      getSequentialId(operationA).compareTo(getSequentialId(operationB));
}
