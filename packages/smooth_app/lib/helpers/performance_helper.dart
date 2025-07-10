import 'package:flutter/foundation.dart';

/// Simple performance monitoring helper for debugging performance issues.
/// Only active in debug mode to avoid affecting release performance.
class PerformanceHelper {
  static final Map<String, Stopwatch> _stopwatches = <String, Stopwatch>{};
  
  /// Start timing an operation
  static void startTimer(String name) {
    if (!kDebugMode) return;
    
    final Stopwatch stopwatch = Stopwatch()..start();
    _stopwatches[name] = stopwatch;
  }
  
  /// Stop timing an operation and log the result
  static void stopTimer(String name, {String? details}) {
    if (!kDebugMode) return;
    
    final Stopwatch? stopwatch = _stopwatches[name];
    if (stopwatch == null) {
      debugPrint('⚠️ Performance timer "$name" was not started');
      return;
    }
    
    stopwatch.stop();
    final int milliseconds = stopwatch.elapsedMilliseconds;
    
    // Log warning if operation took too long
    String emoji = '⏱️';
    if (milliseconds > 1000) {
      emoji = '🐌'; // Very slow
    } else if (milliseconds > 500) {
      emoji = '⚠️'; // Slow
    } else if (milliseconds > 100) {
      emoji = '⚡'; // Noticeable
    }
    
    final String message = '$emoji Performance: $name took ${milliseconds}ms'
        '${details != null ? ' ($details)' : ''}';
    
    if (milliseconds > 100) {
      // Log warnings for operations taking longer than 100ms
      debugPrint(message);
    }
    
    _stopwatches.remove(name);
  }
  
  /// Time an async operation
  static Future<T> timeAsync<T>(
    String name,
    Future<T> Function() operation, {
    String? details,
  }) async {
    startTimer(name);
    try {
      return await operation();
    } finally {
      stopTimer(name, details: details);
    }
  }
  
  /// Time a synchronous operation
  static T timeSync<T>(
    String name,
    T Function() operation, {
    String? details,
  }) {
    startTimer(name);
    try {
      return operation();
    } finally {
      stopTimer(name, details: details);
    }
  }
}