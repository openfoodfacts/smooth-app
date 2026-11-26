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

    // Forward to Sentry Logs (Sentry.logger). The SDK's beforeSendLog callback
    // drops these in release builds; safe to call always.
    _forwardToSentryLogs(level, message, ex: ex, tag: tag);

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

  /// Sends the log to Sentry Logs; silently ignored when the SDK logger
  /// is a no-op (release builds, or before SDK init).
  void _forwardToSentryLogs(
    String fimberLevel,
    String message, {
    dynamic ex,
    String? tag,
  }) {
    final Map<String, SentryAttribute>? attributes = tag != null
        ? <String, SentryAttribute>{'tag': SentryAttribute.string(tag)}
        : null;
    try {
      switch (fimberLevel) {
        case 'V':
          Sentry.logger.trace(message, attributes: attributes);
        case 'D':
          Sentry.logger.debug(message, attributes: attributes);
        case 'W':
          Sentry.logger.warn(message, attributes: attributes);
        case 'E':
          Sentry.logger.error(
            ex != null ? '$message | $ex' : message,
            attributes: attributes,
          );
        case 'I':
        default:
          Sentry.logger.info(message, attributes: attributes);
      }
    } catch (_) {
      // Logging must never break the app.
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
