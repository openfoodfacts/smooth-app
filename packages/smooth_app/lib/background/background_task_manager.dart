import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/data_models/login_result.dart';
import 'package:smooth_app/database/dao_instant_string.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Management of background tasks: single thread, block, restart, display.
class BackgroundTaskManager {
  BackgroundTaskManager._(this.localDatabase, this.queue);

  final LocalDatabase localDatabase;
  final BackgroundTaskQueue queue;

  static Map<BackgroundTaskQueue, BackgroundTaskManager>? _instances;

  static BackgroundTaskManager getInstance(
    final LocalDatabase localDatabase, {
    required final BackgroundTaskQueue queue,
  }) {
    if (_instances == null) {
      final Map<BackgroundTaskQueue, BackgroundTaskManager> result =
          <BackgroundTaskQueue, BackgroundTaskManager>{};
      for (final BackgroundTaskQueue queue in BackgroundTaskQueue.values) {
        result[queue] = BackgroundTaskManager._(localDatabase, queue);
      }
      _instances ??= result;
    }
    return _instances![queue]!;
  }

  /// Returns [DaoInstantString] key for tasks.
  static String _taskIdToDaoInstantStringKey(final String taskId) =>
      'task:$taskId';

  /// Returns [DaoInstantString] key for task errors.
  static String taskIdToErrorDaoInstantStringKey(final String taskId) =>
      'taskError:$taskId';

  /// Runs all background task queues.
  static void runAgain(
    final LocalDatabase localDatabase, {
    final bool forceNowIfPossible = false,
  }) {
    for (final BackgroundTaskQueue queue in BackgroundTaskQueue.values) {
      getInstance(
        localDatabase,
        queue: queue,
      )._run(
        forceNowIfPossible: forceNowIfPossible,
      );
    }
  }

  /// Adds a task to the pending task list.
  Future<void> add(final BackgroundTask task) async {
    final String taskId = task.uniqueId;
    await DaoInstantString(localDatabase).put(
      _taskIdToDaoInstantStringKey(taskId),
      jsonEncode(task.toJson()),
    );
    await DaoStringList(localDatabase).add(queue.tagTaskQueue, taskId);
    await task.preExecute(localDatabase);
    _run(forceNowIfPossible: true);
  }

  /// Finishes a task cleanly.
  ///
  /// That includes:
  /// * running the task's `postExecute` method.
  /// * removing a task from the task lists.
  /// Most of the time this method is used for garbage collecting, that's why
  /// the [success] parameter is set to `false` by default.
  Future<void> _finishTask(
    final String taskId, {
    final bool success = false,
  }) async {
    final BackgroundTask? task = _get(taskId);
    if (task != null) {
      await task.postExecute(localDatabase, success);
    }
    await DaoStringList(localDatabase).remove(queue.tagTaskQueue, taskId);
    await DaoInstantString(localDatabase)
        .put(_taskIdToDaoInstantStringKey(taskId), null);
    await DaoInstantString(localDatabase)
        .put(taskIdToErrorDaoInstantStringKey(taskId), null);
    localDatabase.notifyListeners();
  }

  /// Returns the related task, or null but that is unexpected.
  BackgroundTask? _get(final String taskId) {
    try {
      final String? json = DaoInstantString(localDatabase)
          .get(_taskIdToDaoInstantStringKey(taskId));
      if (json == null) {
        // unexpected
        return null;
      }
      final Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;
      final String processName = BackgroundTask.getProcessName(map);
      for (final OperationType operationType in OperationType.values) {
        if (processName == operationType.processName) {
          _debugPrint('found: $processName, $map');
          return operationType.fromJson(map);
        }
      }
    } catch (e) {
      // unexpected
      _debugPrint('_get exception: $e');
    }
    return null;
  }

  /// Returns the "now" timestamp if we can run now, or `null`.
  ///
  /// With [forceNowIfPossible] we can be more aggressive and force the decision
  /// of running now or at least just after the current running block.
  int? _canStartNow(final bool forceNowIfPossible) {
    final int now = LocalDatabase.nowInMillis();
    final int? latestRunStart =
        localDatabase.daoIntGet(queue.tagLastStartTimestamp);
    final int? latestRunStop =
        localDatabase.daoIntGet(queue.tagLastStopTimestamp);
    if (_running) {
      // if pretending to be running but started a very very long time ago
      if (latestRunStart != null &&
          latestRunStart + queue.aLongEnoughTimeInMilliseconds < now) {
        // we assume we can run now.
        return now;
      }
      // let's try again at the end of the current run.
      if (forceNowIfPossible) {
        _forceRunAgain = true;
      }
      return null;
    }
    // if the last run stopped correctly or was started a long time ago.
    if (latestRunStart == null ||
        latestRunStart + queue.aLongEnoughTimeInMilliseconds < now) {
      // if the last run stopped not enough time ago.
      if (latestRunStop != null &&
          latestRunStop + queue.minimumDurationBetweenRuns >= now) {
        // let's apply that minimum duration if there's no rush
        if (!forceNowIfPossible) {
          return null;
        }
      }
      return now;
    }
    return null;
  }

  /// Signals we've just finished working and that we're ready for a new run.
  Future<void> _justFinished() async {
    await localDatabase.daoIntPut(queue.tagLastStartTimestamp, null);
    await localDatabase.daoIntPut(
      queue.tagLastStopTimestamp,
      LocalDatabase.nowInMillis(),
    );
  }

  bool _running = false;

  /// Flag to say: I know you're running, please try again, it's worth it.
  bool _forceRunAgain = false;

  /// Runs all the pending tasks, and then smoothly ends, without awaiting.
  ///
  /// Can be called in 2 cases:
  /// 1. we've just created a task and we really want it to be executed ASAP
  /// `forceNowIfPossible = true`
  /// 2. we're just checking casually if there are pending tasks
  /// `forceNowIfPossible = false`
  void _run({final bool forceNowIfPossible = false}) =>
      unawaited(_runAsync(forceNowIfPossible));

  /// Runs all the pending tasks, and then smoothly ends.
  ///
  /// If a task fails, we continue with the other tasks: and we'll retry the
  /// failed tasks later.
  /// If a task fails and another task with the same stamp comes after,
  /// we can remove the failed task from the list: it would have been
  /// overwritten anyway.
  Future<void> _runAsync(final bool forceNowIfPossible) async {
    final int? now = _canStartNow(forceNowIfPossible);
    if (now == null) {
      return;
    }
    _running = true;

    /// Will also set the "latest start timestamp".
    /// With this, we can detect a run that went wrong.
    /// Like, still running 1 hour later.
    await localDatabase.daoIntPut(queue.tagLastStartTimestamp, now);
    bool runAgain = true;
    while (runAgain) {
      runAgain = false;
      final List<BackgroundTask> tasks = await _getAllTasks();
      for (final BackgroundTask task in tasks) {
        await task.recover(localDatabase);
      }
      for (final BackgroundTask task in tasks) {
        final String taskId = task.uniqueId;
        try {
          await _setTaskErrorStatus(taskId, taskStatusStarted);
          await task.execute(localDatabase);
          await _finishTask(taskId, success: true);
          if (task.hasImmediateNextTask) {
            runAgain = true;
          }
        } catch (e) {
          // Most likely, no internet, no reason to go on.
          if (LoginResult.isNoNetworkException(e.toString())) {
            await _setTaskErrorStatus(taskId, taskStatusNoInternet);
            await _justFinished();
            return;
          }
          debugPrint('Background task error ($e)');
          Logs.e('Background task error', ex: e);
          await _setTaskErrorStatus(taskId, '$e');
        }
      }
      await _justFinished();
      if (!runAgain) {
        if (_forceRunAgain) {
          runAgain = true;
          _forceRunAgain = false;
        }
      }
    }
    _running = false;
  }

  Future<void> _setTaskErrorStatus(
    final String taskId,
    final String status,
  ) async {
    _debugPrint('setStatus - $taskId: $status');
    final String key = taskIdToErrorDaoInstantStringKey(taskId);
    if (DaoInstantString(localDatabase).get(key) == taskStatusStopAsap) {
      // the task is supposed to be stopped asap and it's a good moment for that
      await _finishTask(taskId);
      return;
    }
    await DaoInstantString(localDatabase).put(key, status);
    localDatabase.notifyListeners();
  }

  /// Removes a task ASAP.
  ///
  /// Returns true if managed to remove the task immediately.
  /// Returns false if the task will be removed next time it's possible.
  Future<bool> removeTaskAsap(final String taskId) async {
    final String? status = DaoInstantString(localDatabase)
        .get(taskIdToErrorDaoInstantStringKey(taskId));
    if (status == taskStatusStarted) {
      // that value will be detected later
      await _setTaskErrorStatus(taskId, taskStatusStopAsap);
      return false;
    }
    await _finishTask(taskId);
    return true;
  }

  /// Forged task status: "Stop that task ASAP!".
  static const String taskStatusStopAsap = '!';

  /// Forged task status: "Just started!".
  static const String taskStatusStarted = '*';

  /// Forged task status: "No internet, try later!".
  static const String taskStatusNoInternet = 'X';

  // TODO(monsieurtanuki): get rid of this once we're relaxed about the tasks.
  void _debugPrint(final String message) {
    // debugPrint('${LocalDatabase.nowInMillis()} $queue $message');
  }

  /// Returns the list of tasks we can run now.
  ///
  /// We put in the list:
  /// * tasks that are not delayed (e.g. [BackgroundTaskRefreshLater])
  /// * only the latest task for a given stamp (except for OTHER uploads)
  Future<List<BackgroundTask>> _getAllTasks() async {
    _debugPrint('get all tasks/0');
    final List<BackgroundTask> result = <BackgroundTask>[];
    final List<String> list = localDatabase.getAllTaskIds(
      queue.tagTaskQueue,
    );
    final List<String> removeTaskIds = <String>[];
    if (list.isEmpty) {
      return result;
    }
    for (final String taskId in list) {
      final BackgroundTask? task = _get(taskId);
      if (task == null) {
        // unexpected, but let's remove that null task anyway.
        _debugPrint('get all tasks/unexpected/$taskId');
        removeTaskIds.add(taskId);
        continue;
      }
      if (!task.mayRunNow()) {
        _debugPrint('get all tasks/maynotrun/$taskId');
        // let's ignore this task: it's not supposed to be run now.
        continue;
      }
      // now let's get rid of stamp duplicates.
      final String stamp = task.stamp;
      _debugPrint('task $taskId, stamp: $stamp');
      if (task.isDeduplicable()) {
        int? removeMe;
        for (int i = 0; i < result.length; i++) {
          // it's the same stamp, we can remove the previous task.
          // it would have been overwritten anyway.
          if (result[i].stamp == stamp) {
            final String removeTaskId = result[i].uniqueId;
            _debugPrint('duplicate stamp, task $removeTaskId being removed...');
            removeTaskIds.add(removeTaskId);
            removeMe = i;
            break;
          }
        }
        if (removeMe != null) {
          result.removeAt(removeMe);
        }
      } else {
        _debugPrint('is "not deduplicable" task!');
      }
      result.add(task);
    }
    for (final String taskId in removeTaskIds) {
      await _finishTask(taskId);
    }
    _debugPrint('get all tasks returned (begin)');
    int i = 0;
    for (final BackgroundTask task in result) {
      _debugPrint('* task #${i++}: ${task.uniqueId} / ${task.stamp}');
    }
    _debugPrint('get all tasks returned (end)');
    _debugPrint('get all tasks/9');
    return result;
  }
}
