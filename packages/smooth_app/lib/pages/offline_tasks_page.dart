import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

class OfflineTaskPage extends StatefulWidget {
  const OfflineTaskPage();

  @override
  State<OfflineTaskPage> createState() => _OfflineTaskState();
}

class _OfflineTaskState extends State<OfflineTaskPage> {
  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final BackgroundTaskManager manager = BackgroundTaskManager(localDatabase);
    final bool blocked = manager.blocked;
    final List<String> taskIds = manager.getAllTaskIds();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Background Tasks'),
        actions: <Widget>[
          IconButton(
            icon: Icon(blocked ? Icons.toggle_on : Icons.toggle_off),
            onPressed: () async {
              manager.blocked = !blocked;
              setState(() {});
              manager.run();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Background Tasks are now ${manager.blocked ? 'blocked' : 'NOT blocked'}',
                  ),
                  duration: SnackBarDuration.medium,
                ),
              );
            },
          )
        ],
      ),
      body: taskIds.isEmpty
          ? const Center(child: EmptyScreen())
          : ListView.builder(
              itemCount: taskIds.length,
              itemBuilder: (final BuildContext context, final int index) {
                final String taskId = taskIds[index];
                return ListTile(
                  title: Text(OperationType.getBarcode(taskId)),
                  subtitle: Text(
                    OperationType.getOperationType(taskId)?.toString() ??
                        'unknown operation type',
                  ),
                );
              },
            ),
    );
  }
}

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No Pending Tasks'));
  }
}
