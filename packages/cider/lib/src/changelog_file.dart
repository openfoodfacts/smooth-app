import 'dart:io';

import 'package:change/change.dart';
import 'package:path/path.dart';

class ChangelogFile {
  ChangelogFile(this._dir);

  static const name = 'CHANGELOG.md';

  final String _dir;

  /// Updates the changelog in-place
  void update(Changelog Function(Changelog changelog) mutate) =>
      _write(mutate(_read()));

  /// Reads the changelog from file
  Changelog _read() => Changelog.fromLines(
      (_file..createSync(recursive: true)).readAsLinesSync());

  void _write(Changelog changelog) => _file.writeAsStringSync(changelog.dump());

  File get _file => File(join(_dir, name));
}
