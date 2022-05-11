import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';

class TrackingDatabaseHelper {
  const TrackingDatabaseHelper(this._localDatabase);
  final LocalDatabase _localDatabase;

  /// Returns the amount the user has opened the app
  int getAppVisits() {
    const String userVisits = 'appVisits';

    final DaoInt daoInt = DaoInt(_localDatabase);

    int visits = daoInt.get(userVisits) ?? 0;
    visits++;
    daoInt.put(userVisits, visits);

    return visits;
  }

  int? getPreviousVisitUnix() {
    const String latestVisit = 'previousVisitUnix';

    final DaoInt daoInt = DaoInt(_localDatabase);

    final int? latestVisit = daoInt.get(latestVisit);

    daoInt.put(
      latestVisit,
      DateTime.now().millisecondsSinceEpoch,
    );

    return latestVisit;
  }

  int? getFirstVisitUnix() {
    const String firstVisit = 'firstVisitUnix';

    final DaoInt daoInt = DaoInt(_localDatabase);

    final int? firstVisit = daoInt.get(firstVisit);

    if (firstVisit == null) {
      daoInt.put(
        firstVisit,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    return firstVisit;
  }
}
