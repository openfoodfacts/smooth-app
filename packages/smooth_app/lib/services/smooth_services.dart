// ignore_for_file: non_constant_identifier_names

import 'package:app_store_shared/app_store_shared.dart';
import 'package:smooth_app/services/app_store/app_store_service.dart';
import 'package:smooth_app/services/logs/logs_fimber_impl.dart';
import 'package:smooth_app/services/logs/smooth_logs_service.dart';

/// List of services (logs, analytics…) available in the app
class SmoothServices {
  factory SmoothServices() {
    return _singleton;
  }

  SmoothServices._internal() {
    _logsService = LogsService();
    _appStoreService = AppStoreService();
  }

  static final SmoothServices _singleton = SmoothServices._internal();
  late LogsService _logsService;
  late AppStoreService _appStoreService;

  Future<void> init(AppStore appStore) {
    return Future.wait<dynamic>(<Future<dynamic>>[
      _logsService.attach(FimberLogImpl()),
      _appStoreService.attach(AppStoreWrapper(appStore)),
    ]);
  }
}

LogsService get Logs => SmoothServices()._logsService;

AppStoreService get ApplicationStore => SmoothServices()._appStoreService;
