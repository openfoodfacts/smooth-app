import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/analytics_http_client.dart';

void main() {
  group('AnalyticsHttpClient', () {
    late AnalyticsHttpClient client;
    late http.MockClient mockClient;

    setUp(() {
      // Create a mock HTTP client that returns a simple response
      mockClient = MockClient((http.BaseRequest request) async {
        return http.Response('test response', 200, headers: <String, String>{
          'content-type': 'application/json',
        });
      });
      client = AnalyticsHttpClient(innerClient: mockClient);
    });

    tearDown(() {
      client.close();
    });

    test('sends HTTP requests successfully', () async {
      final http.Response response = await client.get(
        Uri.parse('https://world.openfoodfacts.org/api/v3/product/test.json'),
      );

      expect(response.statusCode, equals(200));
      expect(response.body, equals('test response'));
    });

    test('works with POST requests', () async {
      final http.Response response = await client.post(
        Uri.parse('https://world.openfoodfacts.org/cgi/product_jqm2.pl'),
        body: <String, String>{'test': 'data'},
      );

      expect(response.statusCode, equals(200));
      expect(response.body, equals('test response'));
    });

    test('can be closed without errors', () {
      expect(() => client.close(), returnsNormally);
    });

    test('uses inner client when analytics is disabled', () async {
      // In test environment, analytics is typically disabled by default
      final http.Response response = await client.get(
        Uri.parse('https://world.openfoodfacts.org/api/v3/product/test.json'),
      );

      // Verify the request went through (the mock client returns 200)
      expect(response.statusCode, equals(200));
    });
  });

  group('AnalyticsHttpClient with custom inner client', () {
    test('respects custom inner client configuration', () async {
      final http.MockClient customMock = MockClient(
        (http.BaseRequest request) async {
          return http.Response('custom response', 201);
        },
      );
      final AnalyticsHttpClient client = AnalyticsHttpClient(
        innerClient: customMock,
      );

      final http.Response response = await client.get(
        Uri.parse('https://world.openfoodfacts.org/api/v3/product/test.json'),
      );

      expect(response.statusCode, equals(201));
      expect(response.body, equals('custom response'));
      client.close();
    });
  });
}
