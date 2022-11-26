import 'dart:async';

mixin CameraScannerLogMixin {
  final StreamController<CameraScannerLog> _controller =
      StreamController<CameraScannerLog>.broadcast();

  void addLog(
      {required String message, dynamic exception, StackTrace? stackTrace}) {
    if (!_controller.isClosed) {
      _controller.add(
        CameraScannerLog(
          message,
          exception: exception,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Stream<CameraScannerLog> get controller => _controller.stream;

  Future<dynamic> disposeLogs() => _controller.close();
}

class CameraScannerLog {
  const CameraScannerLog(
    this.message, {
    this.exception,
    this.stackTrace,
  });

  final String message;
  final dynamic exception;
  final StackTrace? stackTrace;
}
