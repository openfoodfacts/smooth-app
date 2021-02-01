import 'dart:io';

import 'package:cider/src/config.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:version_manipulation/mutations.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class Application {
  Application({String projectRoot = '.'})
      : _pubspec = File(join(projectRoot, 'pubspec.yaml'));

  final File _pubspec;

  /// Bumps pubspec version y applying the [mutation]
  String bump(VersionMutation mutation) {
    final current = _readVersion();
    final updated = mutation(current);
    _writeVersion(updated);
    return updated.toString();
  }

  /// Reads the current project version from pubspec.yaml
  String readVersion() => _readVersion().toString();

  /// Sets the [version] to pubspec.yaml
  void setVersion(String version) {
    _writeVersion(Version.parse(version));
  }

  Version _readVersion() {
    final yaml = loadYaml(_pubspec.readAsStringSync());
    return Version.parse(yaml['version']);
  }

  void _writeVersion(Version version) {
    final yaml = YamlEditor(_pubspec.readAsStringSync());
    yaml.update(['version'], version.toString());
    _pubspec.writeAsStringSync(yaml.toString());
  }
}
