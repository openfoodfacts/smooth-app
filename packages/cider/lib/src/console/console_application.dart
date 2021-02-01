import 'package:args/command_runner.dart';
import 'package:change/change.dart';
import 'package:cider/cider.dart';
import 'package:cider/src/console/command/bump_command.dart';
import 'package:cider/src/console/command/describe_command.dart';
import 'package:cider/src/console/command/log_change_command.dart';
import 'package:cider/src/console/command/release_command.dart';
import 'package:cider/src/console/command/version_command.dart';
import 'package:cider/src/console/command/wrapper.dart';
import 'package:cider/src/console/console.dart';
import 'package:version_manipulation/mutations.dart';

class ConsoleApplication extends CommandRunner<int> {
  ConsoleApplication(String name, {Console console})
      : super(name, 'Dart packages maintenance') {
    console ??= Console.stdio();
    argParser
      ..addOption('project-root',
          help: 'Path to the project root', defaultsTo: '.');

    addCommand(
      Wrapper('Manipulates the CHANGELOG', 'log', [
        'cl',
        'changelog'
      ], [
        LogChangeCommand(
            'addition',
            ['a', 'add', 'added'],
            'Logs an unreleased ADDITION to CHANGELOG.md',
            ChangeType.addition,
            console),
        LogChangeCommand(
            'change',
            ['c', 'ch', 'changed'],
            'Logs an unreleased CHANGE to CHANGELOG.md',
            ChangeType.change,
            console),
        LogChangeCommand(
            'deprecation',
            ['d', 'dep', 'deprecated'],
            'Logs an unreleased DEPRECATION to CHANGELOG.md',
            ChangeType.deprecation,
            console),
        LogChangeCommand(
            'removal',
            ['r', 'rem', 'removed', 'del', 'delete', 'deleted'],
            'Logs an unreleased REMOVAL to CHANGELOG.md',
            ChangeType.removal,
            console),
        LogChangeCommand('fix', ['f', 'fixed'],
            'Logs an unreleased FIX to CHANGELOG.md', ChangeType.fix, console),
        LogChangeCommand(
            'security',
            ['s', 'sec'],
            'Logs an unreleased SECURITY CHANGE to CHANGELOG.md',
            ChangeType.security,
            console),
      ]),
    );
    addCommand(Wrapper('Bumps the package version', 'bump', [], [
      BumpCommand('breaking', BumpBreaking(), console),
      BumpCommand('major', BumpMajor(), console),
      BumpCommand('minor', BumpMinor(), console),
      BumpCommand('patch', BumpPatch(), console),
      BumpCommand('build', BumpBuild(), console),
    ]));
    addCommand(VersionCommand(console));
    addCommand(DescribeCommand(console));
    addCommand(ReleaseCommand(console));
  }
}
