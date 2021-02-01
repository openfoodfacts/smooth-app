import 'package:args/command_runner.dart';
import 'package:cider/src/application.dart';

abstract class ApplicationCommand extends Command<int> {
  Application createApp() =>
      Application(projectRoot: globalResults['project-root']);
}
