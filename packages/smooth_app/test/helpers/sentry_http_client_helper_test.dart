import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/sentry_http_client_helper.dart';

void main() {
  group('SentryHttpClientHelper', () {
    tearDown(() {
      AnalyticsHelper.debugIsAnalyticsEnabledOverride = null;
      AnalyticsHelper.debugIsCrashEnabledOverride = null;
      SentryHttpClientHelper.debugSpanFactory = null;
    });

    test('tracing requires both analytics and crash reporting consent', () {
      AnalyticsHelper.debugIsAnalyticsEnabledOverride = () => true;
      AnalyticsHelper.debugIsCrashEnabledOverride = () => false;

      expect(AnalyticsHelper.debugCrashReportsEnabled, isFalse);
      expect(AnalyticsHelper.isTracingEnabled, isFalse);

      AnalyticsHelper.debugIsCrashEnabledOverride = () => true;

      expect(AnalyticsHelper.debugCrashReportsEnabled, isTrue);
      expect(AnalyticsHelper.isTracingEnabled, isTrue);

      AnalyticsHelper.debugIsAnalyticsEnabledOverride = () => false;

      expect(AnalyticsHelper.isTracingEnabled, isFalse);
    });

    test(
      'propagates traceparent and finishes span with response status',
      () async {
        AnalyticsHelper.debugIsAnalyticsEnabledOverride = () => true;
        AnalyticsHelper.debugIsCrashEnabledOverride = () => true;
        final _RecordingSpan span = _RecordingSpan();
        SentryHttpClientHelper.debugSpanFactory =
            (String operation, String description) {
              expect(operation, 'http.client');
              expect(description, startsWith('GET http://127.0.0.1:'));
              return span;
            };

        final Completer<String?> traceparent = Completer<String?>();
        final HttpServer server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          0,
        );
        final StreamSubscription<HttpRequest> subscription = server.listen((
          HttpRequest request,
        ) {
          traceparent.complete(request.headers.value('traceparent'));
          request.response.statusCode = HttpStatus.noContent;
          unawaited(request.response.close());
        });
        final HttpClient client = SentryHttpClientHelper.wrapHttpClient(
          HttpClient(),
        );
        addTearDown(() async {
          client.close(force: true);
          await subscription.cancel();
          await server.close(force: true);
        });

        final HttpClientRequest request = await client.getUrl(
          Uri.parse('http://127.0.0.1:${server.port}/product/123'),
        );
        final HttpClientResponse response = await request.close();
        await response.drain<void>();

        expect(
          await traceparent.future,
          '00-0123456789abcdef0123456789abcdef-0123456789abcdef-01',
        );
        expect(span.status, const SpanStatus.ok());
        expect(span.finishCalls, 1);
      },
    );

    test(
      'finishes span with an error when opening the request fails',
      () async {
        AnalyticsHelper.debugIsAnalyticsEnabledOverride = () => true;
        AnalyticsHelper.debugIsCrashEnabledOverride = () => true;
        final _RecordingSpan span = _RecordingSpan();
        SentryHttpClientHelper.debugSpanFactory =
            (String operation, String description) => span;

        final HttpClient client = SentryHttpClientHelper.wrapHttpClient(
          _FailingHttpClient(),
        );
        addTearDown(() => client.close(force: true));
        await expectLater(
          client.getUrl(Uri.parse('http://127.0.0.1/unavailable')),
          throwsA(isA<SocketException>()),
        );

        expect(span.status, const SpanStatus.internalError());
        expect(span.throwable, isA<SocketException>());
        expect(span.finishCalls, 1);
      },
    );
  });
}

class _FailingHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Future<HttpClientRequest>.error(const SocketException('unavailable'));

  @override
  void close({bool force = false}) {}
}

class _RecordingSpan extends Mock implements ISentrySpan {
  _RecordingSpan()
    : _traceHeader = SentryTraceHeader(
        SentryId.fromId('0123456789abcdef0123456789abcdef'),
        SpanId.fromId('0123456789abcdef'),
        sampled: true,
      );

  final SentryTraceHeader _traceHeader;
  SpanStatus? _status;
  Object? _throwable;
  int finishCalls = 0;

  @override
  SpanStatus? get status => _status;

  @override
  set status(SpanStatus? value) => _status = value;

  @override
  Object? get throwable => _throwable;

  @override
  set throwable(dynamic value) => _throwable = value as Object?;

  @override
  SentryTraceHeader toSentryTrace() => _traceHeader;

  @override
  void setData(String key, dynamic value) {}

  @override
  Future<void> finish({
    SpanStatus? status,
    DateTime? endTimestamp,
    Hint? hint,
  }) async {
    _status = status ?? _status;
    finishCalls++;
  }
}
