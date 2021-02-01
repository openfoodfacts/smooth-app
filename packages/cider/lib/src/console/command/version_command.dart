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
    //argResults.rest.first
    return _setVersion('release/1.1.1');
  }

  int _setVersion(String version) {
    try {
      var aStr = version.replaceAll(RegExp(r'[^0-9.]'), '');
      _console.log('Version: $aStr');
      createApp().setVersion(aStr);
    } on FormatException {
      _console.error('Invalid version "$version".');
      return ExitCode.applicationError;
    }
    _console.log(version);
    return ExitCode.ok;
  }
}
