import 'dart:convert';

import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/database/dao_instant_string.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';

/// Management of background tasks: single thread, block, restart, display.
class BackgroundTaskManager {
  BackgroundTaskManager(this.localDatabase);

  final LocalDatabase localDatabase;

  /// [DaoInstantString] key for "Should we block the background tasks?".
  ///
  /// Value is null for "No we shouldn't".
  /// It's probably just a temporary debug use-case. Will we keep it?
  static const String _daoInstantStringBlockKey = 'taskManager/block';

  /// Returns [DaoInstantString] key for tasks.
  static String _taskIdToDaoInstantStringKey(final String taskId) =>
      'task:$taskId';

  /// [DaoStringList] key for the list of tasks.
  static const String _daoStringListKey = DaoStringList.keyTasks;

  /// Adds a task to the pending task list.
  Future<void> add(final AbstractBackgroundTask task) async {
    final String taskId = task.uniqueId;
    await DaoInstantString(localDatabase).put(
      _taskIdToDaoInstantStringKey(taskId),
      jsonEncode(task.toJson()),
    );
    await DaoStringList(localDatabase).add(_daoStringListKey, taskId);
    await task.preExecute(localDatabase);
    run(); // no await
  }

  /// Removes a task from the pending task list
  Future<void> _remove(final String taskId) async {
    await DaoStringList(localDatabase).remove(_daoStringListKey, taskId);
    await DaoInstantString(localDatabase)
        .put(_taskIdToDaoInstantStringKey(taskId), null);
  }

  /// Returns the related task, or null but that is unexpected.
  AbstractBackgroundTask? _get(final String taskId) {
    try {
      final String? json = DaoInstantString(localDatabase)
          .get(_taskIdToDaoInstantStringKey(taskId));
      if (json == null) {
        // unexpected
        return null;
      }
      final Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;
      return AbstractBackgroundTask.fromJson(map);
    } catch (e) {
      // unexpected
      return null;
    }
  }

  /// [DaoInt] key we use to store the latest start timestamp.
  static const String _lastStartTimestampKey = 'taskLastStartTimestamp';

  /// Duration in millis after which we can imagine the previous run failed.
  static const int _aLongEnoughTimeInMilliseconds = 3600 * 1000;

  /// Returns true if we can run now.
  ///
  /// Will also set the "latest start timestamp".
  /// With this, we can detect a run that went wrong.
  /// Like, still running 1 hour later.
  bool _canStartNow() {
    final DaoInt daoInt = DaoInt(localDatabase);
    final int now = LocalDatabase.nowInMillis();
    final int? latestRunStart = daoInt.get(_lastStartTimestampKey);
    // TODO(monsieurtanuki): add minimum duration between runs, like 5 minutes?
    if (latestRunStart == null ||
        latestRunStart + _aLongEnoughTimeInMilliseconds < now) {
      daoInt.put(_lastStartTimestampKey, now); // no await, it's ok
      return true;
    }
    return false;
  }

  /// Signals we've just finished working and that we're ready for a new run.
  void _justFinished() =>
      DaoInt(localDatabase).put(_lastStartTimestampKey, null);

  bool get blocked =>
      DaoInstantString(localDatabase).get(_daoInstantStringBlockKey) != null;

  set blocked(final bool block) => DaoInstantString(localDatabase).put(
        _daoInstantStringBlockKey,
        block ? '' : null,
      );

  /// Runs all the pending tasks, until it crashes.
  Future<void> run() async {
    if (!_canStartNow()) {
      return;
    }
    AbstractBackgroundTask? nextTask;
    try {
      while ((nextTask = await _getNextTask()) != null) {
        if (blocked) {
          return;
        }
        await _runTask(nextTask!);
      }
    } catch (e) {
      return;
    } finally {
      _justFinished();
    }
  }

  /// Runs a single task. Possible exception.
  Future<void> _runTask(final AbstractBackgroundTask task) async {
    await task.execute(localDatabase);
    await task.postExecute(localDatabase);
    await _remove(task.uniqueId);
  }

  /// Returns the next task we can run now.
  Future<AbstractBackgroundTask?> _getNextTask() async {
    final List<String> list = getAllTaskIds();
    if (list.isEmpty) {
      return null;
    }
    for (final String taskId in list) {
      final AbstractBackgroundTask? task = _get(taskId);
      if (task == null) {
        await _remove(taskId);
        continue;
      }
      if (task.mayRunNow()) {
        return task;
      }
    }
    return null;
  }

  /// Returns all the task ids.
  List<String> getAllTaskIds() =>
      DaoStringList(localDatabase).getAll(_daoStringListKey);
}
