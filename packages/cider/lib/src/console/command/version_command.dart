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
    var aStr = 'aa/1.1.1';
    //var aStr = argResults.rest.first.replaceAll(RegExp(r'[^0-9.]'), '');
    return _setVersion(aStr);
  }

  int _setVersion(String versionToSet) {
    try {
      createApp().setVersion(versionToSet);
    } on FormatException {
      _console.error('Invalid version test "$versionToSet".');
      return ExitCode.applicationError;
    }
    _console.log(version);
    return ExitCode.ok;
  }
}
