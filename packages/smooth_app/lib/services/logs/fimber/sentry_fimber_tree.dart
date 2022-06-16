import 'package:fimber/fimber.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Custom Fimber [LogTree] that send logs to Sentry
class SentryFimberTree extends LogTree {
  SentryFimberTree({
    this.logLevels = CustomFormatTree.defaultLevels,
  });

  final List<String> logLevels;

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
      Sentry.captureMessage(
        message,
        level: _convertLevel(level),
        hint: tag,
      );
    }
  }

  @override
  List<String> getLevels() => logLevels;

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
