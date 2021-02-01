import 'package:cider/src/application_exception.dart';
import 'package:cider/src/console/command/application_command.dart';
import 'package:cider/src/console/console.dart';
import 'package:cider/src/console/exit_code.dart';
import 'package:intl/intl.dart';

class ReleaseCommand extends ApplicationCommand {
  ReleaseCommand(this._console) {
    argParser
      ..addOption('date',
          help: 'Release date',
          defaultsTo: DateFormat('y-MM-dd').format(DateTime.now()));
  }

  final Console _console;

  @override
  String get description => 'Adds a new release to the changelog';

  @override
  final name = 'release';

  @override
  int run() {
    final app = createApp();
    try {
      app.release(argResults['date']);
      return ExitCode.ok;
    } on ApplicationException catch (e) {
      _console.error(e);
      return ExitCode.applicationError;
    }
  }
}
