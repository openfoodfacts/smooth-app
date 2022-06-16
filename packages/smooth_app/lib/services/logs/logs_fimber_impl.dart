import 'dart:io';

import 'package:fimber_io/fimber_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/services/logs/fimber/files_fimber_tree.dart';
import 'package:smooth_app/services/logs/fimber/sentry_fimber_tree.dart';
import 'package:smooth_app/services/logs/smooth_logs_service.dart';

/// On debug builds: device logs + file (all levels)
/// On release builds : device logs (only errors), sentry (all levels) and
/// file (only errors & info)
class FimberLogImpl implements AppLogService {
  static const List<String> _allLogLevels = <String>['E', 'I', 'D', 'V', 'W'];
  static const List<String> _prodLogLevels = <String>['E', 'I'];

  // Link to a file tree impl (required for exporting logs)
  late FileFimberTree _fileTree;

  @override
  Future<void> init() async {
    if (kReleaseMode) {
      Fimber.plantTree(
        DebugTree(
          logLevels: <String>['E'],
        ),
      );
      _fileTree = FileFimberTree(
        DataSize.mega(1),
        filenamePrefix: await _filesPrefix,
        logLevels: _prodLogLevels,
      );
      Fimber.plantTree(
        SentryFimberTree(logLevels: _allLogLevels),
      );
    } else {
      Fimber.plantTree(
        DebugTree(logLevels: _allLogLevels),
      );

      _fileTree = FileFimberTree(
        DataSize.mega(1),
        filenamePrefix: await _filesPrefix,
        logLevels: _allLogLevels,
      );
    }

    Fimber.plantTree(_fileTree);
  }

  Future<String> get _filesPrefix => _filesDirectory
      .then((Directory dir) => join(dir.absolute.path, 'app_logs'));

  Future<Directory> get _filesDirectory => getApplicationSupportDirectory()
      .then((Directory dir) => Directory(join(dir.absolute.path, 'logs')))
      .then((Directory dir) => dir.create(recursive: true));

  @override
  void log(
    LogLevel level,
    String message, {
    String? tag,
    dynamic ex,
    StackTrace? stacktrace,
  }) {
    Fimber.log(
      _getFimberLogLevel(level),
      message,
      tag: tag ?? _generateTag(),
      ex: ex,
      stacktrace: stacktrace,
    );
  }

  @override
  void d(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log('D', message,
        tag: tag ?? _generateTag(), ex: ex, stacktrace: stacktrace);
  }

  @override
  void e(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log('E', message,
        tag: tag ?? _generateTag(), ex: ex, stacktrace: stacktrace);
  }

  @override
  void i(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log('I', message,
        tag: tag ?? _generateTag(), ex: ex, stacktrace: stacktrace);
  }

  @override
  void v(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log('V', message,
        tag: tag ?? _generateTag(), ex: ex, stacktrace: stacktrace);
  }

  @override
  void w(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log('W', message,
        tag: tag ?? _generateTag(), ex: ex, stacktrace: stacktrace);
  }

  String _getFimberLogLevel(LogLevel level) {
    switch (level) {
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

  String _generateTag() {
    return StackTrace.current.toString().split('\n')[4].split('.')[0];
  }

  @override
  List<String> get logFilesPaths {
    return <String>[_fileTree.outputFileName];
  }
}
