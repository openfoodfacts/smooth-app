import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:task_manager/task_manager.dart';

/// Runs whenever a task is started in the background.
/// Whatever invoked with TaskManager.addTask() will be run in this method.
/// Gets automatically invoked when there is a task added to the queue and the network conditions are favorable.
Future<TaskResult> callbackDispatcher(
  LocalDatabase localDatabase,
) async {
  await TaskManager().init(
    runTasksInIsolates: false,
    executor: (Task inputData) async {
      final AbstractBackgroundTask? taskData =
          AbstractBackgroundTask.fromTask(inputData);
      if (taskData == null) {
        return TaskResult.success;
      }
      return taskData.execute(localDatabase);
    },
  );
  return TaskResult.success;
}
