part of '../user_preferences.dart';

/// When we add/remove entries in the [UserPreferences] class, we need to
/// add a new level and ensure we do a proper migration
class UserPreferencesMigrationTool {
  const UserPreferencesMigrationTool._();

  static final Iterable<UserPreferencesMigration> _versions =
      <UserPreferencesMigration>[
        const _UserPreferencesMigrationV1(),
        const _UserPreferencesMigrationV2(),
        const _UserPreferencesMigrationV3(),
      ];

  static Future<void> onUpgrade(
    UserPreferences preferences,
    int? oldVersion,
    int newVersion,
  ) async {
    if (oldVersion == newVersion) {
      return;
    }

    for (final UserPreferencesMigration migration in _versions) {
      if ((oldVersion ?? 0) >= migration.version) {
        continue;
      }

      await migration.onUpgrade(preferences, oldVersion, newVersion);
    }
  }
}

abstract interface class UserPreferencesMigration {
  const UserPreferencesMigration();

  Future<void> onUpgrade(
    UserPreferences preferences,
    int? oldVersion,
    int newVersion,
  );

  int get version;
}

class _UserPreferencesMigrationV1 extends UserPreferencesMigration {
  const _UserPreferencesMigrationV1();

  @override
  Future<void> onUpgrade(
    UserPreferences preferences,
    int? oldVersion,
    int newVersion,
  ) async {
    final bool? crashReporting = preferences._sharedPreferences.getBool(
      UserPreferences._TAG_CRASH_REPORTS,
    );
    if (crashReporting != null) {
      await preferences.setUserTracking(crashReporting);
    }
  }

  @override
  int get version => 1;
}

class _UserPreferencesMigrationV2 extends UserPreferencesMigration {
  const _UserPreferencesMigrationV2();

  @override
  Future<void> onUpgrade(
    UserPreferences preferences,
    int? oldVersion,
    int newVersion,
  ) async {
    /// With version == null and 1, [_TAG_USER_GROUP] is missing
  }

  @override
  int get version => 2;
}

class _UserPreferencesMigrationV3 extends UserPreferencesMigration {
  const _UserPreferencesMigrationV3();

  @override
  Future<void> onUpgrade(
    UserPreferences preferences,
    int? oldVersion,
    int newVersion,
  ) async {
    if (preferences._sharedPreferences.getBool('_TAG_IS_FIRST_SCAN') ?? false) {
      await preferences.incrementScanCount();
    }
  }

  @override
  int get version => 3;
}
