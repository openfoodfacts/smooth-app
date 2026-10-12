import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/services/logs/fimber/fimber_helper.dart';
import 'package:smooth_app/services/logs/fimber/trees/debug_fimber_tree.dart';
import 'package:smooth_app/services/logs/fimber/trees/file_fimber_tree.dart';
import 'package:smooth_app/services/logs/fimber/trees/sentry_fimber_tree.dart';
import 'package:smooth_app/services/logs/smooth_log_levels.dart';
import 'package:smooth_app/services/logs/smooth_logs_service.dart';

/// On debug builds: device logs + file (all levels)
/// On release builds : device logs (only errors), Sentry (all levels) and
/// file (only errors & info)
class FimberLogImpl implements AppLogService {
  // Link to a file tree impl (required for exporting logs)
  late FileFimberTree _fileTree;

  @override
  Future<void> init() async {
    if (kReleaseMode) {
      Fimber.plantTree(DebugTree(logLevels: <String>['E']));
      _fileTree = FileFimberTree(
        outputFile: await _fileName,
        logLevels: LogLevels.prodLogLevels,
      );
      Fimber.plantTree(SentryFimberTree(logLevels: LogLevels.allLogLevels));
    } else {
      Fimber.plantTree(DebugFimberTree(logLevels: LogLevels.allLogLevels));

      _fileTree = FileFimberTree(
        outputFile: await _fileName,
        logLevels: LogLevels.allLogLevels,
      );
    }

    Fimber.plantTree(_fileTree);

    log(LogLevel.info, 'New app session started');
  }

  Future<File> get _fileName => _filesDirectory.then(
    (Directory dir) => File(join(dir.absolute.path, 'app_logs.log')),
  );

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
      tag: tag ?? _defaultTag,
      ex: ex,
      stacktrace: stacktrace,
    );
  }

  @override
  void d(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log(
      'D',
      message,
      tag: tag ?? _defaultTag,
      ex: ex,
      stacktrace: stacktrace,
    );
  }

  @override
  void e(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log(
      'E',
      message,
      tag: tag ?? _defaultTag,
      ex: ex,
      stacktrace: stacktrace,
    );
  }

  @override
  void i(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log(
      'I',
      message,
      tag: tag ?? _defaultTag,
      ex: ex,
      stacktrace: stacktrace,
    );
  }

  @override
  void v(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log(
      'V',
      message,
      tag: tag ?? _defaultTag,
      ex: ex,
      stacktrace: stacktrace,
    );
  }

  @override
  void w(String message, {String? tag, dynamic ex, StackTrace? stacktrace}) {
    Fimber.log(
      'W',
      message,
      tag: tag ?? _defaultTag,
      ex: ex,
      stacktrace: stacktrace,
    );
  }

  String _getFimberLogLevel(LogLevel level) => level.fimberLevel;

  String get _defaultTag {
    final String tag = StackTrace.current
        .toString()
        .split('\n')[4]
        .split('.')[0];

    // Some tags looks like "#1    some text" -> we only use "some text"
    if (tag.startsWith('#')) {
      return tag.substring(tag.indexOf(' '));
    } else {
      return tag;
    }
  }

  @override
  List<String> get logFilesPaths {
    return <String>[_fileTree.outputFile.absolute.path];
  }
}
