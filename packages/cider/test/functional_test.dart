import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cider/src/console/console_application.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'mock_console.dart';

void main() {
  Directory temp;
  MockConsole console;
  CommandRunner<int> app;
  String changelogPath;
  String pubspecPath;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp();
    changelogPath = join(temp.path, 'CHANGELOG.md');
    pubspecPath = join(temp.path, 'pubspec.yaml');

    console = MockConsole();
    app = ConsoleApplication('ci', console: console);
  });

  tearDown(() async {});

  group('Changelog', () {
    test('Add entries to the CHANGELOG', () async {
      await File('test/samples/step1.md').copy(changelogPath);
      expect(
          await app.run([
            'log',
            'change',
            'Programmatically added change',
            '--project-root',
            temp.path
          ]),
          0);
      expect(
          await app.run([
            'log',
            'd',
            'Programmatically added deprecation',
            '--project-root',
            temp.path
          ]),
          0);
      expect(File(changelogPath).readAsStringSync(),
          File('test/samples/step2.md').readAsStringSync());
    });
  });

  group('Bump', () {
    test('minor', () async {
      await File('test/samples/pubspec-1.0.0.yaml').copy(pubspecPath);
      expect(await app.run(['bump', 'minor', '--project-root', temp.path]), 0);
      expect(File(pubspecPath).readAsStringSync(),
          File('test/samples/pubspec-1.1.0.yaml').readAsStringSync());
    });

    test('patch, keeping build, printing new version', () async {
      await File('test/samples/pubspec-1.0.0+beta.yaml').copy(pubspecPath);
      expect(
          await app
              .run(['bump', 'patch', '-b', '-p', '--project-root', temp.path]),
          0);
      expect(
          File(pubspecPath).readAsStringSync().trim(),
          File('test/samples/pubspec-1.0.1+beta.yaml')
              .readAsStringSync()
              .trim());
      expect(console.logs.single, '1.0.1+beta');
    });

    test('patch, keeping pre-release tag and build, printing new version',
        () async {
      await File('test/samples/pubspec-1.1.0-alpha+42.yaml').copy(pubspecPath);
      expect(
          await app.run(['bump', 'patch', '-brp', '--project-root', temp.path]),
          0);
      expect(console.logs.single, '1.1.1-alpha+42');
    });
  });

  group('Release', () {
    test('successful', () async {
      await File('test/samples/step2.md').copy(changelogPath);
      await File('test/samples/pubspec-1.1.0.yaml').copy(pubspecPath);
      await File('test/samples/.cider.yaml')
          .copy(join(temp.path, '.cider.yaml'));
      expect(
          await app.run(
              ['release', '--date', '2018-10-18', '--project-root', temp.path]),
          0);
      expect(File(changelogPath).readAsStringSync(),
          File('test/samples/step3.md').readAsStringSync());
    });

    test('existing version', () async {
      await File('test/samples/step2.md').copy(changelogPath);
      await File('test/samples/pubspec-1.0.0.yaml').copy(pubspecPath);
      await File('test/samples/.cider.yaml')
          .copy(join(temp.path, '.cider.yaml'));
      expect(await app.run(['release', '--project-root', temp.path]), 64);
      expect(File(changelogPath).readAsStringSync(),
          File('test/samples/step2.md').readAsStringSync());
    });
  });

  group('Version', () {
    test('Print', () async {
      await File('test/samples/step3.md').copy(changelogPath);
      await File('test/samples/pubspec-1.1.0.yaml').copy(pubspecPath);
      expect(await app.run(['version', '--project-root', temp.path]), 0);
      expect(console.logs.single, '1.1.0');
    });
    test('Set successfully', () async {
      await File('test/samples/pubspec-1.1.0.yaml').copy(pubspecPath);
      expect(
          await app.run(['--project-root', temp.path, 'version', '1.2.3-beta']),
          0);
      expect(console.logs.single, '1.2.3-beta');
      expect(await app.run(['version', '--project-root', temp.path]), 0);
      expect(console.logs[1], '1.2.3');
    });
    test('Set errors out', () async {
      await File('test/samples/pubspec-1.1.0.yaml').copy(pubspecPath);
      expect(
          await app.run(['--project-root', temp.path, 'version', 'foo']), 64);
      expect(console.errors.single, 'Invalid version "foo".');
      expect(await app.run(['version', '--project-root', temp.path]), 0);
      expect(console.logs.single, '1.1.0');
    });
  });

  group('Describe', () {
    test('Latest', () async {
      await File('test/samples/step3.md').copy(changelogPath);
      await File('test/samples/pubspec-1.1.0.yaml').copy(pubspecPath);
      expect(await app.run(['describe', '--project-root', temp.path]), 0);
      expect(console.logs.single, '''## [1.1.0] - 2018-10-18
### Changed
- Change #1
- Change #2
- Programmatically added change

### Deprecated
- Programmatically added deprecation

[1.1.0]: https://github.com/example/project/compare/1.0.0...1.1.0''');
    });

    test('provided', () async {
      await File('test/samples/step3.md').copy(changelogPath);
      await File('test/samples/pubspec-1.1.0.yaml').copy(pubspecPath);
      expect(
          await app.run(['describe', '1.0.0', '--project-root', temp.path]), 0);
      expect(console.logs.single, '''## 1.0.0 - 2018-10-15
### Added
- Initial version of the example''');
    });
  });
}
