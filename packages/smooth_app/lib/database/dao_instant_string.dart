import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Where we store strings that need INSTANT access (= not lazy, no await).
class DaoInstantString extends AbstractDao {
  DaoInstantString(super.localDatabase);

  static const String _hiveBoxName = 'instantString';

  static const MethodChannel _backupChannel = MethodChannel(
    'openfoodfacts.smooth_app/backup',
  );

  @override
  Future<void> init() async {
    final Box<String> box = await Hive.openBox<String>(_hiveBoxName);
    await _excludeFromIosBackup(box.path);
  }

  /// Keeps the file out of the iCloud and Finder backups.
  ///
  /// Done at each launch: some file operations, like the compaction of Hive,
  /// reset the attribute.
  static Future<void> _excludeFromIosBackup(String? path) async {
    if (!Platform.isIOS || path == null) {
      return;
    }

    try {
      await _backupChannel.invokeMethod<void>('excludeFromBackup', path);
    } catch (e) {
      Logs.e('Backup exclusion failed (${e.runtimeType})');
    }
  }

  @override
  void registerAdapter() {}

  Box<String> _getBox() => Hive.box<String>(_hiveBoxName);

  String? get(String key) => _getBox().get(key);

  Future<void> put(String key, String? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);
}
