import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';

class TrackingDatabaseHelper {
  const TrackingDatabaseHelper(this._localDatabase);
  final LocalDatabase _localDatabase;

  /// Returns the amount the user has opened the app
  int getAppVisits() {
    const String _userVisits = 'appVisits';

    final DaoInt daoInt = DaoInt(_localDatabase);

    int visits = daoInt.get(_userVisits) ?? 0;
    visits++;
    daoInt.put(_userVisits, visits);

    return visits;
  }

  int? getPreviousVisitUnix() {
    const String _latestVisit = 'previousVisitUnix';

    final DaoInt daoInt = DaoInt(_localDatabase);

    final int? latestVisit = daoInt.get(_latestVisit);

    daoInt.put(
      _latestVisit,
      DateTime.now().millisecondsSinceEpoch,
    );

    return latestVisit;
  }

  int? getFirstVisitUnix() {
    const String _firstVisit = 'firstVisitUnix';

    final DaoInt daoInt = DaoInt(_localDatabase);

    final int? firstVisit = daoInt.get(_firstVisit);

    if (firstVisit == null) {
      daoInt.put(
        _firstVisit,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    return firstVisit;
  }
}
