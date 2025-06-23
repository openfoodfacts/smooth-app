import 'package:fimber/fimber.dart';
import 'package:smooth_app/services/logs/fimber/fimber_helper.dart';
import 'package:smooth_app/services/logs/smooth_log_levels.dart';

abstract class BaseFimberTree extends LogTree {
  BaseFimberTree({required List<LogLevel> logLevels})
    : assert(logLevels.isNotEmpty),
      _logLevels = logLevels
          .map((LogLevel level) => level.fimberLevel)
          .toList(growable: false),
      super();

  final List<String> _logLevels;

  @override
  List<String> getLevels() => _logLevels;
}
