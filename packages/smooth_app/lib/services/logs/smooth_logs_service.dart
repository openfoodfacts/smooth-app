import 'package:smooth_app/services/logs/smooth_log_levels.dart';
import 'package:smooth_app/services/smooth_service.dart';

/// Please use this file for import statements, as it allows to easily change
/// the logging solution

class LogsService extends SmoothService<AppLogService> {
  LogsService() : super();

  void log(
    LogLevel level,
    String message, {
    String? tag,
    dynamic ex,
    StackTrace? stacktrace,
  }) {
    for (final AppLogService logService in impls) {
      logService.log(level, message, tag: tag, ex: ex, stacktrace: stacktrace);
    }
  }

  void d(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) =>
      log(LogLevel.debug, message, tag: tag, ex: ex, stacktrace: stacktrace);

  /// Write an error log
  void e(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) =>
      log(LogLevel.error, message, tag: tag, ex: ex, stacktrace: stacktrace);

  /// Write an info log
  void i(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) =>
      log(LogLevel.info, message, tag: tag, ex: ex, stacktrace: stacktrace);

  /// Write a verbose log
  void v(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) =>
      log(LogLevel.info, message, tag: tag, ex: ex, stacktrace: stacktrace);

  /// Write a warning log
  void w(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) =>
      log(LogLevel.info, message, tag: tag, ex: ex, stacktrace: stacktrace);

  List<String> get logFilesPaths {
    final List<String> files = <String>[];

    for (final AppLogService logService in impls) {
      files.addAll(logService.logFilesPaths);
    }

    return files;
  }
}

abstract class AppLogService implements SmoothServiceImpl {
  @override
  Future<void> init();

  /// Write a debug log
  void d(String message, {String? tag, dynamic ex, StackTrace? stacktrace});

  /// Write an error log
  void e(String message, {String? tag, dynamic ex, StackTrace? stacktrace});

  /// Write an info log
  void i(String message, {String? tag, dynamic ex, StackTrace? stacktrace});

  /// Write a verbose log
  void v(String message, {String? tag, dynamic ex, StackTrace? stacktrace});

  /// Write a warning log
  void w(String message, {String? tag, dynamic ex, StackTrace? stacktrace});

  /// Write a debug log
  void log(
    LogLevel level,
    String message, {
    String? tag,
    dynamic ex,
    StackTrace? stacktrace,
  });

  List<String> get logFilesPaths;
}
