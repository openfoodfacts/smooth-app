import 'package:data_importer/shared/model.dart';
import 'package:data_importer/shared/platform_data_importer.dart';
import 'package:data_importer_shared/data_importer_shared.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Data importer from "V1" apps to Smoothie ("V2") with:
/// - History and user lists
/// - User credentials (login / password)
class ApplicationDataImporter {
  ApplicationDataImporter({
    required this.storage,
    required this.importer,
  });

  /// Some users may have a long history on the previous app, we limit the
  /// import of last scanned products to this constant
  static const int MAX_HISTORY_ITEMS = 1000;

  /// The maximum number of times [startImport] can be called automatically
  static const int MAX_NUMBER_RETRIES = 5;

  /// In the case where we want to change the migration, we store the current
  /// version
  /// V1 = initial version, where all data was kept on the device
  /// V2 = second version, where all data is wiped (if the process is successful)
  static const int _MIGRATION_CURRENT_VERSION = 2;
  static const int _MIGRATION_INITIAL_VERSION = 1;

  static const String _MIGRATION_STATUS_SUCCESS = 'success';
  static const String _MIGRATION_STATUS_ERROR = 'error';

  /// Key to track in which version the migration was accomplished
  static const String _KEY_MIGRATION_VERSION = '_data_importer_version';

  /// Key to track the migration with values being [null] (first time),
  /// [_MIGRATION_STATUS_SUCCESS] or [_MIGRATION_STATUS_ERROR]
  static const String _KEY_GLOBAL_MIGRATION_STATUS = '_data_importer_from_v1';

  /// Key to track the credentials' migration with values being [null]
  /// (first time), [_MIGRATION_STATUS_SUCCESS] or [_MIGRATION_STATUS_ERROR]
  static const String _KEY_CREDENTIALS_MIGRATION_STATUS =
      '_data_importer_credentials_from_v1';

  /// Key to track the lists' migration with values being [null] (first time),
  /// [_MIGRATION_STATUS_SUCCESS] or [_MIGRATION_STATUS_ERROR]
  static const String _KEY_LISTS_MIGRATION_STATUS =
      '_data_importer_lists_from_v1';

  /// Key to track the number of retries, in the case of an error
  /// This limit cannot exceed [_MAX_NUMBER_RETRIES]
  static const String _KEY_MIGRATION_RETRIES = '_data_importer_retries';

  /// --- Errors
  /// In case of a migration error, the error message is available in this key
  static const String _KEY_GLOBAL_MIGRATION_STATUS_ERROR_REASON =
      '_data_importer_error';

  /// In case of a credentials' migration error, the error message is available
  /// in this key
  static const String _KEY_CREDENTIALS_MIGRATION_STATUS_ERROR_REASON =
      '_data_importer_credentials_error';

  /// In case of a lists' migration error, the error message is available in
  /// this key
  static const String _KEY_LISTS_MIGRATION_STATUS_ERROR_REASON =
      '_data_importer_lists_error';

  /// Storage used to save the keys/values defined above
  final FlutterSecureStorage storage;
  final DataImporter importer;

  /// The credentials migration is not mandatory, since the user may have
  /// changed its password
  Future<bool> requireMigration() async {
    final int version = await _getMigrationVersion();

    if (version == _MIGRATION_INITIAL_VERSION) {
      // A previous migration was successful, but data is still on the device
      await _resetRetriesCount();
      return true;
    }

    return version < _MIGRATION_CURRENT_VERSION &&
        (await requireListsMigration());
  }

  Future<bool> requireCredentialsMigration() {
    return storage
        .read(key: _KEY_CREDENTIALS_MIGRATION_STATUS)
        .then((String? value) => value != _MIGRATION_STATUS_SUCCESS);
  }

  Future<bool> requireListsMigration() {
    return storage
        .read(key: _KEY_LISTS_MIGRATION_STATUS)
        .then((String? value) => value != _MIGRATION_STATUS_SUCCESS);
  }

  Future<int> get currentRetriesCount {
    return storage
        .read(key: _KEY_MIGRATION_RETRIES)
        .then((String? value) => value != null ? int.parse(value) : 0);
  }

  Future<void> _incrementRetriesCount() {
    return currentRetriesCount.then(
      (int retries) => storage.write(
        key: _KEY_MIGRATION_RETRIES,
        value: (retries + 1).toString(),
      ),
    );
  }

  Future<void> _resetRetriesCount() {
    return currentRetriesCount.then(
      (int retries) => storage.write(
        key: _KEY_MIGRATION_RETRIES,
        value: '0',
      ),
    );
  }

  /// Start the importation process with both credentials and lists.
  /// If the credentials fail, lists will still be migrated.
  ///
  /// In case of an error, this method can be called [MAX_NUMBER_RETRIES]
  /// automatically or with [forceMechanism] set to [true].
  Future<void> startImport({
    bool forceMechanism = false,
  }) async {
    if (await requireMigration() &&
        (forceMechanism || (await currentRetriesCount) < MAX_NUMBER_RETRIES)) {
      try {
        final PlatformDataImporter platformImporter = PlatformDataImporter();

        if (await _getMigrationVersion() < _MIGRATION_INITIAL_VERSION) {
          /// Import credentials first
          try {
            await startUserCredentialsMigration(platformImporter);
          } catch (err) {
            // Non blocking error (eg: changed password)
          }

          await startListsMigration(platformImporter);
        }

        if (await _deleteDataOnDevice(platformImporter) == true) {
          await _markMigrationAsSuccessful();
        } else {
          await _onMigrationError();
        }
      } catch (err) {
        await _onMigrationError(err: err);
      }
    }
  }

  Future<void> _onMigrationError({dynamic err}) async {
    await _incrementRetriesCount();
    await _markMigrationAsFailed(err);
  }

  Future<void> startListsMigration(
    PlatformDataImporter platformImporter,
  ) async {
    if (await requireListsMigration()) {
      try {
        final ImportableUserData? importLists =
            await platformImporter.importLists();
        if (importLists != null) {
          final bool res = await importer.importLists(
            importLists.toUserData(MAX_HISTORY_ITEMS),
          );

          if (!res) {
            throw Exception('Migration failed!');
          }
        }
      } catch (err) {
        await _markListsMigrationAsFailed(err);
        rethrow;
      }
    }
  }

  Future<void> startUserCredentialsMigration(
    PlatformDataImporter platformImporter,
  ) async {
    if (await requireCredentialsMigration()) {
      try {
        final ImportableUser? user = await platformImporter.importUser();

        if (user != null) {
          await importer.importUser(user.toUser());
        }
      } catch (err) {
        await _markCredentialsMigrationAsFailed(err);
        rethrow;
      }
    }
  }

  Future<bool> _deleteDataOnDevice(PlatformDataImporter platformImporter) =>
      platformImporter.deleteOldDataOnDevice();

  Future<List<void>> _markMigrationAsSuccessful() {
    return Future.wait(<Future<void>>[
      storage.write(
        key: _KEY_GLOBAL_MIGRATION_STATUS,
        value: _MIGRATION_STATUS_SUCCESS,
      ),
      storage.write(
        key: _KEY_CREDENTIALS_MIGRATION_STATUS,
        value: _MIGRATION_STATUS_SUCCESS,
      ),
      storage.write(
        key: _KEY_LISTS_MIGRATION_STATUS,
        value: _MIGRATION_STATUS_SUCCESS,
      ),
      storage.write(
        key: _KEY_GLOBAL_MIGRATION_STATUS_ERROR_REASON,
        value: null,
      ),
      storage.write(
        key: _KEY_CREDENTIALS_MIGRATION_STATUS_ERROR_REASON,
        value: null,
      ),
      storage.write(
        key: _KEY_LISTS_MIGRATION_STATUS_ERROR_REASON,
        value: null,
      ),
      _resetRetriesCount(),
      _saveMigrationVersion(),
    ]);
  }

  Future<List<void>> _markMigrationAsFailed(dynamic error) async {
    return Future.wait(<Future<void>>[
      storage.write(
        key: _KEY_GLOBAL_MIGRATION_STATUS,
        value: _MIGRATION_STATUS_ERROR,
      ),
      storage.write(
        key: _KEY_GLOBAL_MIGRATION_STATUS_ERROR_REASON,
        value: error?.toString(),
      ),
      _saveMigrationVersion(),
    ]);
  }

  Future<List<void>> _markCredentialsMigrationAsFailed(dynamic error) async {
    return Future.wait(<Future<void>>[
      storage.write(
        key: _KEY_CREDENTIALS_MIGRATION_STATUS,
        value: _MIGRATION_STATUS_ERROR,
      ),
      storage.write(
        key: _KEY_CREDENTIALS_MIGRATION_STATUS_ERROR_REASON,
        value: error?.toString(),
      )
    ]);
  }

  Future<List<void>> _markListsMigrationAsFailed(dynamic error) async {
    return Future.wait(<Future<void>>[
      storage.write(
        key: _KEY_LISTS_MIGRATION_STATUS,
        value: _MIGRATION_STATUS_ERROR,
      ),
      storage.write(
        key: _KEY_LISTS_MIGRATION_STATUS_ERROR_REASON,
        value: error?.toString(),
      ),
    ]);
  }

  Future<void> _saveMigrationVersion() async {
    return storage.write(
      key: _KEY_MIGRATION_VERSION,
      value: _MIGRATION_CURRENT_VERSION.toString(),
    );
  }

  /// Returns the current migration version
  /// If no migration was achieved, it will return 0
  Future<int> _getMigrationVersion() async {
    return int.parse(await storage.read(
          key: _KEY_MIGRATION_VERSION,
        ) ??
        '0');
  }
}
