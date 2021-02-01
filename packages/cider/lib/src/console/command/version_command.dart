import 'package:cider/cider.dart';
import 'package:cider/src/console/command/application_command.dart';
import 'package:cider/src/console/console.dart';

class VersionCommand extends ApplicationCommand {
  VersionCommand(this._console);

  final Console _console;

  @override
  final String description = 'Prints/Sets your project version';

  @override
  final String name = 'version';

  @override
  final aliases = <String>['ver'];

  @override
  int run() {
    var aStr = argResults.rest.first.replaceAll(RegExp(r'[^0-9.]'), '');
    return _setVersion(aStr);
  }

  int _setVersion(String version) {
    try {
      createApp().setVersion(version);
    } on FormatException {
      _console.error('Invalid version "$version".');
      return ExitCode.applicationError;
    }
    _console.log(version);
    return ExitCode.ok;
  }
}
