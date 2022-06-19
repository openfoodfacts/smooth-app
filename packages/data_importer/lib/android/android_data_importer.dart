import 'package:data_importer/android/android_sqlite_importer.dart';
import 'package:data_importer/shared/model.dart';
import 'package:data_importer/shared/native_data_importer.dart';
import 'package:data_importer/shared/platform_data_importer.dart';

/// Android Implementation with:
/// - Lists are saved in a SQLite database
/// - Credentials are saved with Shared Preferences
class AndroidDataImporter implements PlatformDataImporter {
  @override
  Future<ImportableUserData?> importLists() {
    return AndroidDatabaseImporter.extract();
  }

  @override
  Future<ImportableUser?> importUser() {
    return NativeDataImporter.getUser();
  }

  @override
  Future<bool> deleteOldDataOnDevice() async {
    return Future.wait<bool>(<Future<bool>>[
      AndroidDatabaseImporter.removeDatabase(),
      NativeDataImporter.clearOldData()
    ]).then((List<bool> value) => !value.contains(false));
  }
}
