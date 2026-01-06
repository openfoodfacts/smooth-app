import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

/// Helper class for creating HTTP clients with optional Sentry tracing.
///
/// This class provides factory methods to create HTTP clients that conditionally
/// enable Sentry tracing based on user consent for both analytics and crash reporting.
class SentryHttpClientHelper {
  /// Creates an HTTP client that conditionally uses Sentry tracing.
  ///
  /// If the user has opted in to both analytics and crash reporting,
  /// returns a [SentryHttpClient] that traces HTTP requests.
  /// Otherwise, returns a standard [http.Client].
  ///
  /// This ensures that no traces are sent to Sentry unless the user
  /// has explicitly consented to both types of data collection.
  static http.Client createClient() {
    if (AnalyticsHelper.isTracingEnabled) {
      return SentryHttpClient();
    } else {
      return http.Client();
    }
  }
}
