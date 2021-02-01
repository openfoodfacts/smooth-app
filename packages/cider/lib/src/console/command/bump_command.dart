import 'package:cider/src/console/command/application_command.dart';
import 'package:cider/src/console/console.dart';
import 'package:cider/src/console/exit_code.dart';
import 'package:version_manipulation/mutations.dart';

class BumpCommand extends ApplicationCommand {
  BumpCommand(this.name, this.mutation, this._console) {
    argParser
      ..addFlag('print',
          help: 'Prints the updated version', abbr: 'p', defaultsTo: false)
      ..addFlag('keep-build',
          help: 'Keeps the build part of the version',
          abbr: 'b',
          defaultsTo: false)
      ..addFlag('keep-pre-release',
          help: 'Keeps the pre-release part of the version',
          abbr: 'r',
          defaultsTo: false);
  }

  final Console _console;

  @override
  String get description => 'Bumps the $name version';

  @override
  final name;
  final VersionMutation mutation;

  @override
  int run() {
    try {
      final updated = createApp().bump(_adjustedMutation);
      if (argResults['print']) _console.log(updated);
      return ExitCode.ok;
    } catch (e) {
      _console.error(e);
      return ExitCode.applicationError;
    }
  }

  VersionMutation get _adjustedMutation {
    var m = mutation;
    if (argResults['keep-pre-release']) m = KeepPreRelease(m);
    if (argResults['keep-build']) m = KeepBuild(m);
    return m;
  }
}
