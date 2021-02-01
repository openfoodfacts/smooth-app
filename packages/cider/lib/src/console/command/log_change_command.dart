import 'package:change/change.dart';
import 'package:cider/cider.dart';
import 'package:cider/src/console/command/application_command.dart';
import 'package:cider/src/console/console.dart';

class LogChangeCommand extends ApplicationCommand {
  LogChangeCommand(
      this.name, this.aliases, this.description, this._type, this._console);

  final Console _console;

  final ChangeType _type;

  @override
  final String description;
  @override
  final String name;
  @override
  final List<String> aliases;

  @override
  int run() {
    if (argResults.rest.isEmpty) {
      _console.error('Please specify the change description');
      return ExitCode.usageException;
    }
    final app = createApp();
    app.logChange(_type, argResults.rest.first);
    return ExitCode.ok;
  }
}
