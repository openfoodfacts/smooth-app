import 'package:badges/badges.dart' as badges;
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
    return badges.Badge(
      badgeColor: Colors.blue.shade900,
      showBadge: true,
      badgeContent: Text(
        '${tasks.length}',
        style: const TextStyle(color: Colors.white),
      ),
      position: badges.BadgePosition.topStart(start: -16),
      child: child,
    );
  }
}
