import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:smooth_app/data_models/background_tasks_model.dart';

import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/local_database.dart';

/// Hive type adapter for [BackgroundTaskModel]
class _BackgroundTaskModel extends TypeAdapter<BackgroundTaskModel> {
  @override
  final int typeId = 2;

  @override
  BackgroundTaskModel read(BinaryReader reader) => BackgroundTaskModel.fromJson(
      jsonDecode(reader.readString()) as Map<String, dynamic>);

  @override
  void write(BinaryWriter writer, BackgroundTaskModel obj) =>
      writer.writeString(jsonEncode(obj.toJson()));
}
class DaoBackgroundTask extends AbstractDao {
  DaoBackgroundTask(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'background_tasks';

  @override
  Future<void> init() async =>
      Hive.openLazyBox<BackgroundTaskModel>(_hiveBoxName);

  @override
  void registerAdapter() => Hive.registerAdapter(_BackgroundTaskModel());

  LazyBox<BackgroundTaskModel> _getBox() =>
      Hive.lazyBox<BackgroundTaskModel>(_hiveBoxName);

  Future<BackgroundTaskModel?> get(final String taskId) async =>
      _getBox().get(taskId);

  Future<Map<String, BackgroundTaskModel>> getAll(
      final List<String> taskId) async {
    final LazyBox<BackgroundTaskModel> box = _getBox();
    final Map<String, BackgroundTaskModel> result =
        <String, BackgroundTaskModel>{};
    for (final String task in taskId) {
      final BackgroundTaskModel? backgroundTaskModel = await box.get(task);
      if (backgroundTaskModel != null) {
        result[task] = backgroundTaskModel;
      }
    }
    return result;
  }

  Future<void> put(final BackgroundTaskModel backgroundTaskModel) async =>
      putAll(<BackgroundTaskModel>[backgroundTaskModel]);

  Future<void> putAll(
      final Iterable<BackgroundTaskModel> backgroundTaskModels) async {
    final Map<String, BackgroundTaskModel> upserts =
        <String, BackgroundTaskModel>{};
    for (final BackgroundTaskModel backgroundTaskModel
        in backgroundTaskModels) {
      upserts[backgroundTaskModel.backgroundTaskId] = backgroundTaskModel;
    }
    await _getBox().putAll(upserts);
  }

  Future<List<String>> getAllKeys() async {
    final LazyBox<BackgroundTaskModel> box = _getBox();
    final List<String> result = <String>[];
    for (final dynamic key in box.keys) {
      result.add(key.toString());
    }
    return result;
  }

  Future<void> delete(final String taskId) async => _getBox().delete(taskId);

  Future<void> deleteAll(final List<String> taskIds) async {
    final LazyBox<BackgroundTaskModel> box = _getBox();
    await box.deleteAll(taskIds);
  }
}
