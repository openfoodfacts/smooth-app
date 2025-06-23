import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/database/local_database.dart';

/// Badge about pending background tasks.
class BackgroundTaskBadge extends StatelessWidget {
  const BackgroundTaskBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    int count = 0;
    for (final BackgroundTaskQueue queue in BackgroundTaskQueue.values) {
      count += localDatabase.getAllTaskIds(queue.tagTaskQueue).length;
    }
    if (count == 0) {
      return child;
    }
    return Badge(
      backgroundColor: Colors.blue.shade900,
      label: Text('$count', style: const TextStyle(color: Colors.white)),
      child: child,
    );
  }
}
