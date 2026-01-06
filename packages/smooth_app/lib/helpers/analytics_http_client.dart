import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

/// A custom HTTP client that conditionally uses Sentry tracing based on
/// analytics and crash reporting opt-in status.
///
/// This client wraps the standard HTTP client and only enables Sentry tracing
/// (which sends trace information to Sentry servers) when the user has opted
/// in to BOTH analytics and crash reporting. When either is disabled, it falls
/// back to the standard HTTP client without any tracing.
///
/// This ensures that:
/// 1. No traces are sent if the user has opted out of analytics (feature tracking)
/// 2. No traces are sent if the user has opted out of crash reporting (Sentry data)
/// 3. User privacy is respected by requiring explicit consent for both types of data collection
class AnalyticsHttpClient extends http.BaseClient {
  AnalyticsHttpClient({http.Client? innerClient})
      : _innerClient = innerClient ?? http.Client();

  final http.Client _innerClient;
  SentryHttpClient? _sentryClient;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Check analytics opt-in at the time of the HTTP call
    // We require both analytics and crash reporting to be enabled for tracing
    if (AnalyticsHelper.isTracingEnabled) {
      // User has opted in to both analytics and crash reporting - use Sentry tracing
      _sentryClient ??= SentryHttpClient(client: _innerClient);
      return _sentryClient!.send(request);
    } else {
      // User has not opted in or has opted out - use regular client
      // Clean up Sentry client if it was previously created
      if (_sentryClient != null) {
        _sentryClient!.close();
        _sentryClient = null;
      }
      return _innerClient.send(request);
    }
  }

  @override
  void close() {
    _sentryClient?.close();
    _innerClient.close();
  }
}
