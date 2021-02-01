import 'package:cider/cider.dart';
import 'package:cider/src/console/command/application_command.dart';
import 'package:cider/src/console/console.dart';

class DescribeCommand extends ApplicationCommand {
  DescribeCommand(this._console);

  final Console _console;
  @override
  final description = 'Prints the changelog entry for the given version';

  @override
  final name = 'describe';

  @override
  final aliases = ['desc'];

  @override
  int run() {
    if (argResults.rest.isEmpty) {
      _console.log(createApp().describe());
    } else {
      _console.log(createApp().describe(argResults.rest.single));
    }
    return ExitCode.ok;
  }
}
