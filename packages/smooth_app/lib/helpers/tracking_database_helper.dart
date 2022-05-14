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
    const String latestVisitKey = 'previousVisitUnix';

    final DaoInt daoInt = DaoInt(_localDatabase);

    final int? latestVisit = daoInt.get(latestVisitKey);

    daoInt.put(
      latestVisitKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    return latestVisit;
  }

  int? getFirstVisitUnix() {
    const String firstVisitKey = 'firstVisitUnix';

    final DaoInt daoInt = DaoInt(_localDatabase);

    final int? firstVisit = daoInt.get(firstVisitKey);

    if (firstVisit == null) {
      daoInt.put(
        firstVisitKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    return firstVisit;
  }
}
