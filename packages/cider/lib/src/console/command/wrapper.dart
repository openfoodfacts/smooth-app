import 'package:args/command_runner.dart';

class Wrapper extends Command<int> {
  Wrapper(
      this.description, this.name, this.aliases, List<Command<int>> children)
      : super() {
    children.forEach(addSubcommand);
  }

  @override
  final description;

  @override
  final name;

  @override
  final aliases;
}
