import 'dart:io';

import 'package:fimber_io/fimber_io.dart';

/// Single file fimber implementation
/// When the maxDataSize is reached, half of the content is removed
class FileFimberTree extends SizeRollingFileTree {
  FileFimberTree(DataSize maxDataSize,
      {CustomFormatTree? logFormat,
      String? filenamePrefix,
      String? filenamePostfix,
      List<String>? logLevels})
      : super(
          maxDataSize,
          logFormat: logFormat ?? CustomFormatTree.defaultFormat,
          filenamePrefix: filenamePrefix ?? 'app_logs',
          filenamePostfix: filenamePostfix ?? '.log',
          logLevels: logLevels ?? CustomFormatTree.defaultLevels,
        );

  @override
  void rollToNextFile() {
    final File file = File(outputFileName);

    if (file.existsSync()) {
      final List<String> content = file.readAsLinesSync();
      file.writeAsStringSync(
          content.sublist((content.length / 2).floor()).join('\n'));
    }
  }

  @override
  String get outputFileName =>
      File('$filenamePrefix$filenamePostfix').absolute.path;
}
