enum LogLevel { debug, error, info, verbose, warning }

class LogLevels {
  static const List<LogLevel> allLogLevels = <LogLevel>[
    LogLevel.error,
    LogLevel.info,
    LogLevel.debug,
    LogLevel.verbose,
    LogLevel.warning,
  ];

  static const List<LogLevel> prodLogLevels = <LogLevel>[
    LogLevel.error,
    LogLevel.info,
    LogLevel.debug,
  ];
}
