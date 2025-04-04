import 'package:flutter/material.dart';
import 'package:smooth_app/database/dao_string_list.dart';

/// Queues for Background Tasks.
enum BackgroundTaskQueue {
  fast(
    tagLastStartTimestamp: 'taskLastStartTimestamp',
    tagLastStopTimestamp: 'taskLastStopTimestamp',
    tagTaskQueue: DaoStringList.keyTasksFast,
    iconData: Icons.bolt,
    aLongEnoughTimeInMilliseconds: 20 * 60 * 1000,
    minimumDurationBetweenRuns: 5 * 1000,
  ),
  slow(
    tagLastStartTimestamp: 'taskLastStartTimestampSlow',
    tagLastStopTimestamp: 'taskLastStopTimestampSlow',
    tagTaskQueue: DaoStringList.keyTasksSlow,
    iconData: Icons.upload,
    aLongEnoughTimeInMilliseconds: 60 * 60 * 1000,
    minimumDurationBetweenRuns: 5 * 1000,
  ),
  longHaul(
    tagLastStartTimestamp: 'taskLastStartTimestampLongHaul',
    tagLastStopTimestamp: 'taskLastStopTimestampLongHaul',
    tagTaskQueue: DaoStringList.keyTasksLongHaul,
    iconData: Icons.download,
    aLongEnoughTimeInMilliseconds: 60 * 60 * 1000,
    minimumDurationBetweenRuns: 60 * 1000,
  );

  const BackgroundTaskQueue({
    required this.tagLastStartTimestamp,
    required this.tagLastStopTimestamp,
    required this.tagTaskQueue,
    required this.iconData,
    required this.aLongEnoughTimeInMilliseconds,
    required this.minimumDurationBetweenRuns,
  });

  /// [DaoInt] key we use to store the latest start timestamp.
  final String tagLastStartTimestamp;

  /// [DaoInt] key we use to store the latest stop timestamp.
  final String tagLastStopTimestamp;

  /// [DaoStringList] key we use to store the task queue.
  final String tagTaskQueue;

  /// Duration in millis after which we can imagine the previous run failed.
  final int aLongEnoughTimeInMilliseconds;

  /// Minimum duration in millis between each run.
  final int minimumDurationBetweenRuns;

  final IconData iconData;
}
