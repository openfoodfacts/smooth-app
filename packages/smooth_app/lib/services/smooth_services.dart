// ignore_for_file: non_constant_identifier_names

import 'package:smooth_app/services/logs/logs_fimber_impl.dart';
import 'package:smooth_app/services/logs/smooth_logs_service.dart';

/// List of services (logs, analytics…) available in the app
class SmoothServices {
  factory SmoothServices() {
    return _singleton;
  }

  SmoothServices._internal() {
    _logsService = LogsService();
  }

  static final SmoothServices _singleton = SmoothServices._internal();
  late LogsService _logsService;

  Future<void> init() {
    return Future.wait<dynamic>(<Future<dynamic>>[
      _logsService.attach(FimberLogImpl()),
    ]);
  }
}

LogsService get Logs => SmoothServices()._logsService;
