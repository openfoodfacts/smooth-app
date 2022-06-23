import 'package:smooth_app/services/logs/smooth_log_levels.dart';

extension LogLevelExtension on LogLevel {
  String get fimberLevel {
    switch (this) {
      case LogLevel.verbose:
        return 'V';
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warning:
        return 'W';
      case LogLevel.error:
        return 'E';
    }
  }
}

extension LogLevelsExtension on Iterable<LogLevel> {
  List<String> get fimberLevels =>
      map((LogLevel level) => level.fimberLevel).toList(growable: false);
}
