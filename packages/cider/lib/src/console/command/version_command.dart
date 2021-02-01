import 'package:cider/cider.dart';
import 'package:cider/src/console/command/application_command.dart';
import 'package:cider/src/console/console.dart';

class VersionCommand extends ApplicationCommand {
  VersionCommand(this._console);

  final Console _console;

  @override
  final String description = 'Prints your project version';

  @override
  final String name = 'version';

  @override
  final aliases = <String>['ver'];

  @override
  int run() {
    if (argResults.rest.isEmpty) {
      return _readVersion();
    }
    return _setVersion(argResults.rest.first);
  }

  int _setVersion(String version) {
    try {
      var aStr = version.replaceAll(RegExp(r'[^0-9.]'), '');
      createApp().setVersion(aStr);
    } on FormatException {
      _console.error('Invalid version "$version".');
      return ExitCode.applicationError;
    }
    _console.log(version);
    return ExitCode.ok;
  }

  int _readVersion() {
    _console.log(createApp().readVersion());
    return ExitCode.ok;
  }
}
