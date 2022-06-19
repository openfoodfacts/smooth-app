import 'package:data_importer/shared/model.dart';
import 'package:data_importer/shared/native_data_importer.dart';
import 'package:data_importer/shared/platform_data_importer.dart';

/// iOS Implementation with:
/// - Lists (only history) are saved in a Realm database
/// - Credentials are saved with NSDefaults & KeyChain
class IOSDataImporter implements PlatformDataImporter {
  /// Only imports history.
  /// User lists were not implemented in V1.
  @override
  Future<ImportableUserData?> importLists() async {
    final dynamic res = await NativeDataImporter.getHistory();

    if (res is List) {
      return ImportableUserData(history: res.cast<String>());
    } else {
      return null;
    }
  }

  /// Imports user credentials (login & password)
  @override
  Future<ImportableUser?> importUser() async {
    return NativeDataImporter.getUser();
  }

  @override
  Future<bool> deleteOldDataOnDevice() {
    return NativeDataImporter.clearOldData();
  }
}
