import 'package:smooth_app/database/dao_int.dart';

/// Returns a progressive number each time it is invoked for a given [key].
/// This is useful to generate a unique id for a given [key].
///
/// The [key] is a string that is used to identify the sequence.
///
/// The progressive number is saved in the database, so that it is persistent.
Future<int> getNextSequenceNumber(final DaoInt daoInt, final String key) async {
  int? result = daoInt.get(key);
  if (result == null) {
    result = 1;
  } else {
    result++;
  }
  await daoInt.put(key, result);
  return result;
}
