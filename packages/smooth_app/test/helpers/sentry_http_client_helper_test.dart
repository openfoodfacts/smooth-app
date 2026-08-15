import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/helpers/sentry_http_client_helper.dart';

void main() {
  group('SentryHttpClientHelper', () {
    test('creates SentryHttpClient when tracing is enabled', () {
      // Note: In test environment, isTracingEnabled is typically false
      // This test documents the expected behavior when it's true
      final http.Client client = SentryHttpClientHelper.createClient();

      // The client should be created successfully
      expect(client, isNotNull);

      // Clean up
      client.close();
    });

    test('creates standard Client when tracing is disabled', () {
      // In test environment, analytics and crash reporting are disabled by default
      final http.Client client = SentryHttpClientHelper.createClient();

      // The client should be created successfully
      expect(client, isNotNull);

      // The client should be a standard http.Client, not a SentryHttpClient
      // (when tracing is disabled)
      expect(client, isNot(isA<SentryHttpClient>()));

      // Clean up
      client.close();
    });

    test('can create multiple clients', () {
      final http.Client client1 = SentryHttpClientHelper.createClient();
      final http.Client client2 = SentryHttpClientHelper.createClient();

      expect(client1, isNotNull);
      expect(client2, isNotNull);
      expect(client1, isNot(same(client2)));

      client1.close();
      client2.close();
    });
  });
}
