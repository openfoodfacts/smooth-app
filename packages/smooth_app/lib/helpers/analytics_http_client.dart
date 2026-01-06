import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

/// A custom HTTP client that conditionally uses Sentry tracing based on
/// analytics opt-in status.
///
/// This client wraps the standard HTTP client and only enables Sentry tracing
/// (which sends trace information to Sentry servers) when the user has opted
/// in to analytics. When analytics is disabled, it falls back to the standard
/// HTTP client without any tracing.
class AnalyticsHttpClient extends http.BaseClient {
  AnalyticsHttpClient({http.Client? innerClient})
      : _innerClient = innerClient ?? http.Client();

  final http.Client _innerClient;
  SentryHttpClient? _sentryClient;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Check analytics opt-in at the time of the HTTP call
    if (AnalyticsHelper.isEnabled) {
      // User has opted in to analytics - use Sentry tracing
      _sentryClient ??= SentryHttpClient(client: _innerClient);
      return _sentryClient!.send(request);
    } else {
      // User has not opted in or has opted out - use regular client
      return _innerClient.send(request);
    }
  }

  @override
  void close() {
    _sentryClient?.close();
    _innerClient.close();
  }
}
