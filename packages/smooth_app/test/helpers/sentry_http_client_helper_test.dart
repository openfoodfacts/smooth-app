import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/sentry_http_client_helper.dart';

void main() {
  group('SentryHttpClientHelper', () {
    tearDown(() {
      // Reset test override after each test
      AnalyticsHelper.debugIsTracingEnabledOverride = null;
    });

    test('creates SentryHttpClient when tracing is enabled', () {
      AnalyticsHelper.debugIsTracingEnabledOverride = () => true;

      final http.Client client = SentryHttpClientHelper.createClient();

      expect(client, isNotNull);
      expect(client, isA<SentryHttpClient>());

      client.close();
    });

    test('creates standard Client when tracing is disabled', () {
      AnalyticsHelper.debugIsTracingEnabledOverride = () => false;

      final http.Client client = SentryHttpClientHelper.createClient();

      expect(client, isNotNull);
      expect(client, isNot(isA<SentryHttpClient>()));

      client.close();
    });

    test('smoke: creates client with default (disabled) tracing', () {
      // Without override, isTracingEnabled is false in test env (no UserPreferences)
      final http.Client client = SentryHttpClientHelper.createClient();

      expect(client, isNotNull);
      expect(client, isNot(isA<SentryHttpClient>()));

      client.close();
    });

    test('can create multiple clients', () {
      AnalyticsHelper.debugIsTracingEnabledOverride = () => false;

      final http.Client client1 = SentryHttpClientHelper.createClient();
      final http.Client client2 = SentryHttpClientHelper.createClient();

      expect(client1, isNotNull);
      expect(client2, isNotNull);
      expect(client1, isNot(same(client2)));

      client1.close();
      client2.close();
    });

    test(
      'wrapHttpClient always wraps but per-request check respects consent',
      () async {
        // This is a smoke test: wrapHttpClient now always returns a wrapper
        // that checks isTracingEnabled per-request. Verify no throw.
        AnalyticsHelper.debugIsTracingEnabledOverride = () => false;
        final HttpClient inner = HttpClient();
        final HttpClient wrapped = SentryHttpClientHelper.wrapHttpClient(inner);
        expect(wrapped, isNotNull);
        // When tracing disabled, wrapper delegates without creating a span
        // (no network call needed to verify).

        // With tracing enabled, wrapper should still be non-null
        AnalyticsHelper.debugIsTracingEnabledOverride = () => true;
        final HttpClient wrapped2 = SentryHttpClientHelper.wrapHttpClient(
          inner,
        );
        expect(wrapped2, isNotNull);

        inner.close();
        // wrapped clients delegate close to inner; closing inner suffices for smoke
      },
    );
  });
}
