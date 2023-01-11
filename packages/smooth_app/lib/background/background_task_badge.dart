import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/database/local_database.dart';

/// Badge about pending background tasks.
class BackgroundTaskBadge extends StatelessWidget {
  const BackgroundTaskBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final List<String> tasks =
        BackgroundTaskManager(localDatabase).getAllTaskIds();
    if (tasks.isEmpty) {
      return child;
    }
    return Badge(
      badgeColor: Colors.blue.shade900,
      showBadge: true,
      badgeContent: Text(
        '${tasks.length}',
        style: const TextStyle(color: Colors.white),
      ),
      position: BadgePosition.topEnd(end: -24),
      child: child,
    );
  }
}
