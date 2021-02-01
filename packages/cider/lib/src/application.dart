import 'dart:io';

import 'package:change/change.dart';
import 'package:cider/src/application_exception.dart';
import 'package:cider/src/config.dart';
import 'package:marker/flavors.dart' as flavors;
import 'package:marker/marker.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:version_manipulation/mutations.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class Application {
  Application({String projectRoot = '.'})
      : _pubspec = File(join(projectRoot, 'pubspec.yaml')),
        _changelog = File(join(projectRoot, 'CHANGELOG.md')),
        _config = Config.readFile(File(join(projectRoot, '.cider.yaml')));

  final File _pubspec;
  final File _changelog;
  final Config _config;

  /// Logs a new entry to the unreleased section of the changelog
  void logChange(ChangeType type, String text) {
    final changelog = _readChangelog();
    changelog.unreleased.section(type).add(text);
    _writeChangelog(changelog);
  }

  /// Bumps pubspec version y applying the [mutation]
  String bump(VersionMutation mutation) {
    final current = _readVersion();
    final updated = mutation(current);
    _writeVersion(updated);
    return updated.toString();
  }

  /// Creates a new release from unreleased changes
  void release(String date) {
    final version = _readVersion().toString();
    final changelog = _readChangelog();
    if (changelog.releases.any((release) => release.version == version)) {
      throw ApplicationException('Release already exists');
    }
    changelog.release(version, date, link: _config.diffLinkTemplate.or(''));
    _writeChangelog(changelog);
  }

  /// Reads the current project version from pubspec.yaml
  String readVersion() => _readVersion().toString();

  /// Sets the [version] to pubspec.yaml
  void setVersion(String version) {
    _writeVersion(Version.parse(version));
  }

  /// Reads the markdown description for the given release
  String describe([String version]) {
    final changelog = _readChangelog();
    if (changelog.releases.isEmpty) throw 'No releases found in CHANGELOG';
    final release = Maybe(version)
        .map((ver) => changelog.releases.firstWhere(
            (release) => release.version == ver,
            orElse: () => throw 'Version $ver not found'))
        .or(changelog.releases.last);
    return render(release.toMarkdown(), flavor: flavors.changelog);
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

  Changelog _readChangelog() => _changelog.existsSync()
      ? Changelog.fromLines(_changelog.readAsLinesSync())
      : Changelog();

  void _writeChangelog(Changelog changelog) =>
      (_changelog..createSync(recursive: true))
          .writeAsStringSync(changelog.dump());
}
