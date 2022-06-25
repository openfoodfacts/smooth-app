import 'package:data_importer/data_importer.dart';
import 'package:data_importer_shared/data_importer_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/data_importer/product_list_import_export.dart';

/// Mechanism used to transfer/import data from V1 apps (Android and iOS)
/// At any time, the current [status] is publicly available.
class SmoothAppDataImporter extends ChangeNotifier {
  SmoothAppDataImporter(this.database);

  /// Database to store lists
  final LocalDatabase database;

  /// Lazy initialized module
  ApplicationDataImporter? _dataImporter;
  SmoothAppDataImporterStatus _status = SmoothAppDataImporterStatus.notStarted;

  void _init() {
    _dataImporter ??= ApplicationDataImporter(
      storage: const FlutterSecureStorage(),
      importer: DataImporter(
        importUser: _importUser,
        importLists: _importLists,
      ),
    );
  }

  void startMigrationAsync({
    bool forceMigration = false,
  }) {
    _init();
    _startMigration(
      forceMigration: forceMigration,
    );
  }

  Future<void> _checkStatus() async {
    if (_status == SmoothAppDataImporterStatus.notStarted) {
      _init();

      if (await _dataImporter!.requireMigration()) {
        _updateStatus(SmoothAppDataImporterStatus.required);
      } else {
        _updateStatus(SmoothAppDataImporterStatus.alreadyDone);
      }
    }
  }

  Future<void> _startMigration({
    bool forceMigration = false,
  }) async {
    await _checkStatus();

    if (forceMigration || await _dataImporter!.requireMigration()) {
      _updateStatus(SmoothAppDataImporterStatus.inProgress);
      await _dataImporter!.startImport(
        forceMechanism: forceMigration,
      );
      _updateStatus(SmoothAppDataImporterStatus.success);
      notifyListeners();
    } else {
      _updateStatus(SmoothAppDataImporterStatus.alreadyDone);
    }
  }

  Future<bool> _importUser(UserCredentials user) {
    return UserManagementProvider().login(
      off.User(
        userId: user.userName,
        password: user.password,
      ),
    );
  }

  Future<bool> _importLists(UserListsData data) {
    return ProductListImportExport().import(
      ImportableLists(data.export()),
      database,
    );
  }

  void _updateStatus(SmoothAppDataImporterStatus status) {
    if (_status != status) {
      _status = status;
      notifyListeners();
    }
  }

  SmoothAppDataImporterStatus get status {
    return _status;
  }
}

enum SmoothAppDataImporterStatus {
  /// Migration was accomplished in a previous run or if it's a brand new install
  alreadyDone,

  /// The current migration is successful
  success,

  /// The current migration has an error
  error,

  /// The current migration is in progress
  inProgress,

  /// No migration  (which can be [alreadyDone])
  required,

  /// No migration started (call [_checkStatus] to update)
  notStarted;

  String printableLabel(AppLocalizations appLocalizations) {
    switch (this) {
      case SmoothAppDataImporterStatus.alreadyDone:
        return appLocalizations.dev_preferences_migration_status_already_done;
      case SmoothAppDataImporterStatus.success:
        return appLocalizations.dev_preferences_migration_status_success;
      case SmoothAppDataImporterStatus.error:
        return appLocalizations.dev_preferences_migration_status_error;
      case SmoothAppDataImporterStatus.inProgress:
        return appLocalizations.dev_preferences_migration_status_in_progress;
      case SmoothAppDataImporterStatus.required:
        return appLocalizations.dev_preferences_migration_status_required;
      case SmoothAppDataImporterStatus.notStarted:
        return appLocalizations.dev_preferences_migration_status_not_started;
    }
  }

  bool get canInitiateMigration => <SmoothAppDataImporterStatus>[
        SmoothAppDataImporterStatus.error,
        SmoothAppDataImporterStatus.required,
        SmoothAppDataImporterStatus.notStarted,
      ].contains(this);
}
