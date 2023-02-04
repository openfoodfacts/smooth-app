import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';

/// Badge about pending background tasks.
class BackgroundTaskBadge extends StatelessWidget {
  const BackgroundTaskBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final List<String> tasks = localDatabase.getAllTaskIds();
    if (tasks.isEmpty) {
      return child;
    }
    return Badge(
      backgroundColor: Colors.blue.shade900,
      label: Text(
        '${tasks.length}',
        style: const TextStyle(color: Colors.white),
      ),
      child: child,
    );
  }
}
