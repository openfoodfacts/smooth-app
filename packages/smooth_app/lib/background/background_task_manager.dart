import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/database/dao_instant_string.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Management of background tasks: single thread, block, restart, display.
class BackgroundTaskManager {
  BackgroundTaskManager(this.localDatabase);

  final LocalDatabase localDatabase;

  /// Returns [DaoInstantString] key for tasks.
  static String _taskIdToDaoInstantStringKey(final String taskId) =>
      'task:$taskId';

  /// Returns [DaoInstantString] key for task errors.
  static String taskIdToErrorDaoInstantStringKey(final String taskId) =>
      'taskError:$taskId';

  /// Adds a task to the pending task list.
  Future<void> add(final AbstractBackgroundTask task) async {
    final String taskId = task.uniqueId;
    await DaoInstantString(localDatabase).put(
      _taskIdToDaoInstantStringKey(taskId),
      jsonEncode(task.toJson()),
    );
    await DaoStringList(localDatabase).add(DaoStringList.keyTasks, taskId);
    await task.preExecute(localDatabase);
    run(); // no await
  }

  /// Removes a task from the pending task list
  Future<void> _remove(final String taskId) async {
    await DaoStringList(localDatabase).remove(DaoStringList.keyTasks, taskId);
    await DaoInstantString(localDatabase)
        .put(_taskIdToDaoInstantStringKey(taskId), null);
    await DaoInstantString(localDatabase)
        .put(taskIdToErrorDaoInstantStringKey(taskId), null);
    localDatabase.notifyListeners();
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

  /// [DaoInt] key we use to store the latest stop timestamp.
  static const String _lastStopTimestampKey = 'taskLastStopTimestamp';

  /// Duration in millis after which we can imagine the previous run failed.
  static const int _aLongEnoughTimeInMilliseconds = 3600 * 1000;

  /// Minimum duration in millis between each run.
  static const int _minimumDurationBetweenRuns = 5 * 1000;

  /// Returns true if we can run now.
  ///
  /// Will also set the "latest start timestamp".
  /// With this, we can detect a run that went wrong.
  /// Like, still running 1 hour later.
  Future<bool> _canStartNow() async {
    final DaoInt daoInt = DaoInt(localDatabase);
    final int now = LocalDatabase.nowInMillis();
    final int? latestRunStart = daoInt.get(_lastStartTimestampKey);
    final int? latestRunStop = daoInt.get(_lastStopTimestampKey);
    // if the last run stopped correctly or was started a long time ago.
    if (latestRunStart == null ||
        latestRunStart + _aLongEnoughTimeInMilliseconds < now) {
      // if the last run stopped not enough time ago.
      if (latestRunStop != null &&
          latestRunStop + _minimumDurationBetweenRuns >= now) {
        return false;
      }
      await daoInt.put(_lastStartTimestampKey, now);
      return true;
    }
    return false;
  }

  /// Signals we've just finished working and that we're ready for a new run.
  Future<void> _justFinished() async {
    await DaoInt(localDatabase).put(_lastStartTimestampKey, null);
    await DaoInt(localDatabase).put(
      _lastStopTimestampKey,
      LocalDatabase.nowInMillis(),
    );
  }

  /// Runs all the pending tasks, and then smoothly ends.
  Future<void> run() async {
    await _run();
    await _justFinished();
  }

  /// Runs all the pending tasks.
  ///
  /// If a task fails, we continue with the other tasks: and we'll retry the
  /// failed tasks later.
  /// If a task fails and another task with the same stamp comes after,
  /// we can remove the failed task from the list: it would have been
  /// overwritten anyway.
  Future<void> _run() async {
    if (!await _canStartNow()) {
      return;
    }
    final List<AbstractBackgroundTask> tasks = await _getAllTasks();
    final Map<String, String> failedTaskFromStamps = <String, String>{};
    for (final AbstractBackgroundTask task in tasks) {
      final String stamp = task.stamp;
      final String taskId = task.uniqueId;
      final String? previousFailedTaskId = failedTaskFromStamps[stamp];
      if (previousFailedTaskId != null) {
        // there was a similar task that failed previously and we can dismiss it
        // as the current one would overwrite it.
        // not only will we spare a to-be-overwritten call, but we avoid the
        // "save latest change" and then "save initial change" dilemma.
        _debugPrint('removing failed task $previousFailedTaskId');
        await _remove(previousFailedTaskId);
        failedTaskFromStamps.remove(stamp);
      }
      try {
        await _runTask(task);
      } catch (e) {
        // Most likely, no internet, no reason to go on.
        if (e.toString().startsWith('Failed host lookup: ')) {
          await DaoInstantString(localDatabase).put(
            taskIdToErrorDaoInstantStringKey(taskId),
            taskStatusNoInternet,
          );
          localDatabase.notifyListeners();
          return;
        }
        debugPrint('Background task error ($e)');
        Logs.e('Background task error', ex: e);
        await DaoInstantString(localDatabase)
            .put(taskIdToErrorDaoInstantStringKey(taskId), '$e');
        failedTaskFromStamps[stamp] = taskId;
        localDatabase.notifyListeners();
      }
    }
  }

  /// Forged task status: "Just started!".
  static const String taskStatusStarted = '*';

  /// Forged task status: "No internet, try later!".
  static const String taskStatusNoInternet = 'X';

  /// Runs a single task. Possible exception.
  Future<void> _runTask(final AbstractBackgroundTask task) async {
    await DaoInstantString(localDatabase).put(
      taskIdToErrorDaoInstantStringKey(task.uniqueId),
      taskStatusStarted,
    );
    localDatabase.notifyListeners();
    await task.execute(localDatabase);
    await task.postExecute(localDatabase);
    await _remove(task.uniqueId);
  }

  // TODO(monsieurtanuki): get rid of this once we're relaxed about the tasks.
  void _debugPrint(final String message) {
    // debugPrint('${LocalDatabase.nowInMillis()} $message');
  }

  /// Returns the list of tasks we can run now.
  ///
  /// We put in the list:
  /// * tasks that are not delayed (e.g. [BackgroundTaskRefreshLater])
  /// * only the latest task for a given stamp (except for OTHER uploads)
  Future<List<AbstractBackgroundTask>> _getAllTasks() async {
    _debugPrint('get all tasks/0');
    final List<AbstractBackgroundTask> result = <AbstractBackgroundTask>[];
    final List<String> list = localDatabase.getAllTaskIds();
    final List<String> duplicateTaskIds = <String>[];
    if (list.isEmpty) {
      return result;
    }
    for (final String taskId in list) {
      final AbstractBackgroundTask? task = _get(taskId);
      if (task == null) {
        // unexpected, but let's remove that null task anyway.
        await _remove(taskId);
        continue;
      }
      if (!task.mayRunNow()) {
        // let's ignore this task: it's not supposed to be run now.
        continue;
      }
      // now let's get rid of stamp duplicates.
      final String stamp = task.stamp;
      _debugPrint('task $taskId, stamp: $stamp');
      // for image/OTHER we don't remove duplicates (they are NOT duplicates)
      if (!BackgroundTaskImage.isOtherStamp(stamp)) {
        int? removeMe;
        for (int i = 0; i < result.length; i++) {
          // it's the same stamp, we can remove the previous task.
          // it would have been overwritten anyway.
          if (result[i].stamp == stamp) {
            final String removeTaskId = result[i].uniqueId;
            _debugPrint('duplicate stamp, task $removeTaskId being removed...');
            duplicateTaskIds.add(removeTaskId);
            removeMe = i;
            break;
          }
        }
        if (removeMe != null) {
          result.removeAt(removeMe);
        }
      } else {
        _debugPrint('is "other" stamp!');
      }
      result.add(task);
    }
    for (final String taskId in duplicateTaskIds) {
      await _remove(taskId);
    }
    _debugPrint('get all tasks returned (begin)');
    int i = 0;
    for (final AbstractBackgroundTask task in result) {
      _debugPrint('* task #${i++}: ${task.uniqueId} / ${task.stamp}');
    }
    _debugPrint('get all tasks returned (end)');
    _debugPrint('get all tasks/9');
    return result;
  }
}
