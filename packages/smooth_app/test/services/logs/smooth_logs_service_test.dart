import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/services/logs/smooth_log_levels.dart';
import 'package:smooth_app/services/logs/smooth_logs_service.dart';

class FakeAppLogService implements AppLogService {
  LogLevel? lastLevel;
  String? lastMessage;

  @override
  Future<void> init() async {}

  @override
  void log(
    LogLevel level,
    String message, {
    dynamic ex,
    StackTrace? stacktrace,
    String? tag,
  }) {
    lastLevel = level;
    lastMessage = message;
  }

  @override
  void d(String message, {dynamic ex, StackTrace? stacktrace, String? tag}) {}

  @override
  void e(String message, {dynamic ex, StackTrace? stacktrace, String? tag}) {}

  @override
  void i(String message, {dynamic ex, StackTrace? stacktrace, String? tag}) {}

  @override
  void v(String message, {dynamic ex, StackTrace? stacktrace, String? tag}) {}

  @override
  void w(String message, {dynamic ex, StackTrace? stacktrace, String? tag}) {}

  @override
  List<String> get logFilesPaths => [];
}

void main() {
  late LogsService logsService;
  late FakeAppLogService fakeLogService;

  setUp(() async {
    logsService = LogsService();
    fakeLogService = FakeAppLogService();

    await logsService.attach(fakeLogService);
  });

  test('forwards verbose messages with LogLevel.verbose', () {
    logsService.v('verbose message');

    expect(fakeLogService.lastLevel, LogLevel.verbose);
    expect(fakeLogService.lastMessage, 'verbose message');
  });

  test('forwards warning messages with LogLevel.warning', () {
    logsService.w('warning message');

    expect(fakeLogService.lastLevel, LogLevel.warning);
    expect(fakeLogService.lastMessage, 'warning message');
  });
}
