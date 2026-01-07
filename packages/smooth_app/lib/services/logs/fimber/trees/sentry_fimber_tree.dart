import 'package:fimber/fimber.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/services/logs/fimber/trees/base_fimber_tree.dart';

/// Custom Fimber [LogTree] that send logs to Sentry
class SentryFimberTree extends BaseFimberTree {
  SentryFimberTree({required super.logLevels});

  @override
  void log(
    String level,
    String message, {
    dynamic ex,
    StackTrace? stacktrace,
    String? tag,
  }) {
    final SentryLevel sentryLevel = _convertLevel(level);

    if (ex != null || sentryLevel == SentryLevel.error) {
      Sentry.captureException(
        ex,
        stackTrace: stacktrace,
        hint: Hint.withMap(<String, Object>{
          'tag': tag ?? '-',
          'message': message,
        }),
      );
    } else {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          timestamp: DateTime.now(),
          level: sentryLevel,
        ),
        hint: tag != null ? Hint.withMap(<String, Object>{'tag': tag}) : null,
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
