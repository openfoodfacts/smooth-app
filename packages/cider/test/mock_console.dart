import 'package:cider/cider.dart';

class MockConsole implements Console {
  final errors = <String>[];
  final logs = <String>[];

  @override
  void error(Object message) {
    errors.add(message.toString());
  }

  @override
  void log(Object message) {
    logs.add(message.toString());
  }
}
