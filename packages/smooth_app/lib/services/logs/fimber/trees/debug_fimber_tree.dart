import 'package:fimber/fimber.dart';
import 'package:smooth_app/services/logs/fimber/fimber_helper.dart';
import 'package:smooth_app/services/logs/smooth_log_levels.dart';

class DebugFimberTree extends DebugTree {
  DebugFimberTree({required List<LogLevel> logLevels})
    : assert(logLevels.isNotEmpty),
      super(
        logLevels: logLevels
            .map((LogLevel level) => level.fimberLevel)
            .toList(growable: false),
      );
}
