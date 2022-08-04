import 'package:fimber/fimber.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/services/logs/fimber/trees/base_fimber_tree.dart';
import 'package:smooth_app/services/logs/smooth_log_levels.dart';

/// Custom Fimber [LogTree] that send logs to Sentry
class SentryFimberTree extends BaseFimberTree {
  SentryFimberTree({
    required List<LogLevel> logLevels,
  }) : super(logLevels: logLevels);

  @override
  void log(
    String level,
    String message, {
    dynamic ex,
    StackTrace? stacktrace,
    String? tag,
  }) {
    if (ex != null) {
      Sentry.captureException(
        ex,
        stackTrace: stacktrace,
        hint: tag,
      );
    } else {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          timestamp: DateTime.now(),
          level: _convertLevel(level),
        ),
        hint: tag,
      );
    }
  }

  SentryLevel _convertLevel(String fimberLevel) {
    switch (fimberLevel) {
      case 'D':
        return SentryLevel.debug;
      case 'W':
        return SentryLevel.warning;
      case 'E':
        return SentryLevel.error;
      case 'V':
      case 'I':
      default:
        return SentryLevel.info;
    }
  }
}
