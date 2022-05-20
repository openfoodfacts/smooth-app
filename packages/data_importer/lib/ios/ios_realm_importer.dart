import 'package:data_importer/data_importer.dart';
import 'package:data_importer/ios/model/realm_history_item.dart';
import 'package:data_importer/shared/model.dart';
import 'package:realm/realm.dart';

/// Import history from V1 (Realm database)
class IOSDatabaseImporter {
  const IOSDatabaseImporter._();

  static Future<ImportableUserData?> extract() async {
    final Configuration config = Configuration(
      <SchemaObject>[HistoryItem.schema],
    );

    final Realm realm = Realm(config);

    final RealmResults<HistoryItem> objects = realm.query<HistoryItem>(
      'TRUEPREDICATE SORT(timestamp DESC) '
      'LIMIT(${ApplicationDataImporter.MAX_HISTORY_ITEMS})',
    );

    final ImportableUserData? res;

    if (objects.isNotEmpty) {
      res = ImportableUserData(
        history: objects.map((HistoryItem element) => element.barcode),
      );
    } else {
      res = null;
    }

    realm.close();
    return res;
  }
}
