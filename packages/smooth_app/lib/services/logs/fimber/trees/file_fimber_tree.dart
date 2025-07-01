import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:intl/intl.dart';
import 'package:smooth_app/services/logs/fimber/trees/base_fimber_tree.dart';

/// Single file fimber implementation
/// When the maxDataSize is reached, half of the content is removed
class FileFimberTree extends BaseFimberTree {
  FileFimberTree({required super.logLevels, required this.outputFile}) {
    outputFile.createSync();
  }

  static final int _maxFileSize = DataSize(megabytes: 5).realSize;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final File outputFile;

  /// Generates the following String:
  /// [level] [tag]: [message]
  ///  [ex]
  ///  [stacktrace]
  @override
  void log(
    String level,
    String message, {
    String? tag,
    dynamic ex,
    StackTrace? stacktrace,
  }) {
    final StringBuffer buffer = StringBuffer(level);

    if (tag != null) {
      buffer.write(' ${_dateFormat.format(DateTime.now())}');
      buffer.write(' $tag');
    }

    buffer.writeln(':$message');
    if (ex != null) {
      buffer.writeln(ex);
    }
    if (stacktrace != null) {
      buffer.writeln(stacktrace.toString());
    }

    _appendToFile(buffer.toString());
    buffer.clear();
  }

  void _appendToFile(String content) {
    // If adding the new line exceeds the max length, we remove half of
    // the content
    if (outputFile.lengthSync() + content.length > _maxFileSize) {
      final List<String> lines = outputFile.readAsLinesSync();
      lines.add(content);

      outputFile.writeAsStringSync(
        lines.sublist((lines.length / 2).round()).join('\n'),
        mode: FileMode.writeOnly,
      );
    } else {
      outputFile.writeAsStringSync(content, mode: FileMode.writeOnlyAppend);
    }
  }
}
