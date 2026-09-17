// dart:convert is required for Encoding type on HttpClientRequest.encoding
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

/// Helper class for creating HTTP clients with optional Sentry tracing.
///
/// This class provides factory methods to create HTTP clients that conditionally
/// enable Sentry tracing based on user consent for both analytics and crash reporting.
class SentryHttpClientHelper {
  const SentryHttpClientHelper._();

  /// Creates an HTTP client that conditionally uses Sentry tracing.
  ///
  /// If the user has opted in to both analytics and crash reporting,
  /// returns a [SentryHttpClient] that traces HTTP requests.
  /// Otherwise, returns a standard [http.Client].
  ///
  /// This ensures that no traces are sent to Sentry unless the user
  /// has explicitly consented to both types of data collection.
  ///
  /// NOTE: consent is captured at creation time. There are currently no
  /// production callers (tests only); if adopted for long-lived/cached
  /// `package:http` clients, the caller MUST recreate the client after
  /// analytics/crash-reporting preferences change, otherwise toggling takes
  /// effect only on recreation. For `dart:io` traffic prefer the
  /// [HttpOverrides] path via [wrapHttpClient], which re-checks consent
  /// per-request.
  static http.Client createClient() {
    if (AnalyticsHelper.isTracingEnabled) {
      return SentryHttpClient(client: http.Client());
    } else {
      return http.Client();
    }
  }

  /// Wraps a dart:io HttpClient with Sentry tracing.
  ///
  /// This is used by HttpOverrides to intercept ALL HTTP requests in the app,
  /// including NetworkImage requests and any direct dart:io HttpClient usage.
  ///
  /// Always wraps; consent is re-checked per-request inside
  /// [_SentryWrappedHttpClient._wrapRequest] so opt-out takes effect
  /// immediately without recreating the cached HttpClient. Note: opt-in
  /// creates new child spans immediately, but if the parent transaction was
  /// sampled `0.0` by `tracesSampler` before opt-in, those children stay
  /// dropped until a new sampled transaction starts (e.g. navigation/restart).
  static HttpClient wrapHttpClient(HttpClient client) {
    return _SentryWrappedHttpClient(client);
  }
}

/// A custom HttpClient that delegates HTTP calls through Sentry tracing.
///
/// This allows us to intercept dart:io HttpClient calls (used by NetworkImage, etc.)
/// and add Sentry tracing infrastructure.
class _SentryWrappedHttpClient implements HttpClient {
  _SentryWrappedHttpClient(this._innerClient);

  final HttpClient _innerClient;

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      _wrapRequest(() => _innerClient.getUrl(url), url, 'GET');

  @override
  Future<HttpClientRequest> postUrl(Uri url) =>
      _wrapRequest(() => _innerClient.postUrl(url), url, 'POST');

  @override
  Future<HttpClientRequest> putUrl(Uri url) =>
      _wrapRequest(() => _innerClient.putUrl(url), url, 'PUT');

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) =>
      _wrapRequest(() => _innerClient.deleteUrl(url), url, 'DELETE');

  @override
  Future<HttpClientRequest> headUrl(Uri url) =>
      _wrapRequest(() => _innerClient.headUrl(url), url, 'HEAD');

  @override
  Future<HttpClientRequest> patchUrl(Uri url) =>
      _wrapRequest(() => _innerClient.patchUrl(url), url, 'PATCH');

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _wrapRequest(() => _innerClient.openUrl(method, url), url, method);

  // Legacy host/port/path family: delegate directly to the inner client.
  // Do NOT round-trip via getUrl(Uri(scheme:..., path: path)) because
  // Uri(path: path) percent-encodes '?'/'#' while SDK HttpClient.open parses
  // them as query/fragment separators. Delegating preserves SDK semantics;
  // _legacyDescUri is for span description only (query/fragment stripped).
  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      _wrapRequest(
        () => _innerClient.get(host, port, path),
        _legacyDescUri('http', host, port, path),
        'GET',
      );

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      _wrapRequest(
        () => _innerClient.post(host, port, path),
        _legacyDescUri('http', host, port, path),
        'POST',
      );

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      _wrapRequest(
        () => _innerClient.put(host, port, path),
        _legacyDescUri('http', host, port, path),
        'PUT',
      );

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _wrapRequest(
        () => _innerClient.delete(host, port, path),
        _legacyDescUri('http', host, port, path),
        'DELETE',
      );

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      _wrapRequest(
        () => _innerClient.head(host, port, path),
        _legacyDescUri('http', host, port, path),
        'HEAD',
      );

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _wrapRequest(
        () => _innerClient.patch(host, port, path),
        _legacyDescUri('http', host, port, path),
        'PATCH',
      );

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) => _wrapRequest(
    () => _innerClient.open(method, host, port, path),
    _legacyDescUri('http', host, port, path),
    method.toUpperCase(),
  );

  /// Builds a description-only Uri for legacy host/port/path calls.
  ///
  /// Mirrors SDK `HttpClient.open` parsing: '?' starts query, '#' starts
  /// fragment. They are stripped here because [sanitizedDescription] never
  /// sends them to Sentry anyway; the actual request uses the raw [path].
  static Uri _legacyDescUri(
    String scheme,
    String host,
    int port,
    String path,
  ) {
    String pathPart = path;
    final int hashIndex = pathPart.indexOf('#');
    if (hashIndex != -1) {
      pathPart = pathPart.substring(0, hashIndex);
    }
    final int queryIndex = pathPart.indexOf('?');
    if (queryIndex != -1) {
      pathPart = pathPart.substring(0, queryIndex);
    }
    return Uri(scheme: scheme, host: host, port: port, path: pathPart);
  }

  /// Returns a sanitized URL for Sentry span descriptions.
  ///
  /// Mirrors Sentry's own [HttpSanitizer] convention: strips query, fragment
  /// and redacts userinfo so PII (search terms, credentials) never lands in
  /// Sentry. Only scheme://host[:port]/path is kept.
  static String sanitizedDescription(String method, Uri url) {
    final StringBuffer buffer = StringBuffer();
    if (url.scheme.isNotEmpty) {
      buffer.write('${url.scheme}://');
    }
    if (url.userInfo.isNotEmpty) {
      buffer.write(
        url.userInfo.contains(':') ? '[Filtered]:[Filtered]@' : '[Filtered]@',
      );
    }
    buffer.write(url.host);
    if (url.hasPort) {
      buffer.write(':${url.port}');
    }
    if (url.path.isNotEmpty) {
      buffer.write(url.path);
    }
    return '$method $buffer';
  }

  Future<HttpClientRequest> _wrapRequest(
    Future<HttpClientRequest> Function() requestFactory,
    Uri url,
    String method,
  ) async {
    // Check consent per-request so opt-out is immediate even for cached clients.
    if (!AnalyticsHelper.isTracingEnabled) {
      return requestFactory();
    }

    // Start a Sentry span for this request (sanitized: no query/fragment/userinfo).
    final ISentrySpan? span = Sentry.getSpan()?.startChild(
      'http.client',
      description: sanitizedDescription(method, url),
    );

    try {
      final HttpClientRequest request = await requestFactory();

      // Propagate distributed-tracing headers so backends can correlate
      // spans. Mirrors Sentry's TracingClient: only when the URL matches
      // tracePropagationTargets, from the child span if present, else from
      // the scope propagation context. Never breaks the request on failure.
      if (_shouldPropagateTrace(url)) {
        try {
          if (span != null) {
            final SentryTraceHeader traceHeader = span.toSentryTrace();
            request.headers.set(traceHeader.name, traceHeader.value);
            final SentryBaggageHeader? baggage = span.toBaggageHeader();
            if (baggage != null) {
              request.headers.set(baggage.name, baggage.value);
            }
          } else {
            final dynamic propagationContext =
                Sentry.currentHub.scope.propagationContext;
            final dynamic traceHeader =
                propagationContext.toSentryTrace() as SentryTraceHeader;
            request.headers.set(traceHeader.name, traceHeader.value);
            final dynamic baggage =
                propagationContext.toBaggageHeader() as SentryBaggageHeader?;
            if (baggage != null) {
              request.headers.set(baggage.name, baggage.value);
            }
          }
        } catch (_) {
          // Tracing must never break the request.
        }
      }
      span?.setData('http.request.method', method);

      // Wrap the request to finish the span when done
      return _SentryWrappedHttpClientRequest(request, span);
    } catch (e) {
      span?.throwable = e;
      span?.status = const SpanStatus.internalError();
      await span?.finish();
      rethrow;
    }
  }

  /// Returns true if [url] matches Sentry's tracePropagationTargets.
  ///
  /// Duplicates SDK logic in `containsTargetOrMatchesRegExp`: empty list
  /// means no propagation; otherwise substring or case-insensitive RegExp
  /// match. Defaults to `['.*']` (propagate everywhere).
  static bool _shouldPropagateTrace(Uri url) {
    final List<String> targets =
        Sentry.currentHub.options.tracePropagationTargets;
    if (targets.isEmpty) {
      return false;
    }
    final String urlString = url.toString();
    for (final String target in targets) {
      if (urlString.contains(target)) {
        return true;
      }
      try {
        if (RegExp(target, caseSensitive: false).hasMatch(urlString)) {
          return true;
        }
      } on FormatException {
        continue;
      }
    }
    return false;
  }

  // Delegate all other properties and methods to the inner client
  @override
  bool get autoUncompress => _innerClient.autoUncompress;

  @override
  set autoUncompress(bool value) => _innerClient.autoUncompress = value;

  @override
  Duration? get connectionTimeout => _innerClient.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) =>
      _innerClient.connectionTimeout = value;

  @override
  Duration get idleTimeout => _innerClient.idleTimeout;

  @override
  set idleTimeout(Duration value) => _innerClient.idleTimeout = value;

  @override
  int? get maxConnectionsPerHost => _innerClient.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? value) =>
      _innerClient.maxConnectionsPerHost = value;

  @override
  String? get userAgent => _innerClient.userAgent;

  @override
  set userAgent(String? value) => _innerClient.userAgent = value;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) => _innerClient.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) => _innerClient.addProxyCredentials(host, port, realm, credentials);

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) => _innerClient.authenticate = f;

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String? realm)?
    f,
  ) => _innerClient.authenticateProxy = f;

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) => _innerClient.badCertificateCallback = callback;

  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )?
    f,
  ) => _innerClient.connectionFactory = f;

  @override
  set findProxy(String Function(Uri url)? f) => _innerClient.findProxy = f;

  @override
  set keyLog(Function(String line)? callback) => _innerClient.keyLog = callback;

  @override
  void close({bool force = false}) => _innerClient.close(force: force);
}

/// Wraps HttpClientRequest to finish the Sentry span when the response is received.
class _SentryWrappedHttpClientRequest implements HttpClientRequest {
  _SentryWrappedHttpClientRequest(this._request, this._span);

  final HttpClientRequest _request;
  final ISentrySpan? _span;
  bool _spanFinished = false;

  Future<void> _finishWithStatus(SpanStatus status) async {
    if (_spanFinished) {
      return;
    }
    _spanFinished = true;
    _span?.status = status;
    await _span?.finish();
  }

  // Fire-and-forget for synchronous abort path.
  void _finishWithStatusSync(SpanStatus status) {
    if (_spanFinished) {
      return;
    }
    _spanFinished = true;
    _span?.status = status;
    // abort() is synchronous by dart:io contract
    _span?.finish();
  }

  @override
  Future<HttpClientResponse> close() async {
    try {
      final HttpClientResponse response = await _request.close();
      await _finishWithStatus(
        SpanStatus.fromHttpStatusCode(response.statusCode),
      );
      return response;
    } catch (e) {
      _span?.throwable = e;
      await _finishWithStatus(const SpanStatus.internalError());
      rethrow;
    }
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    _finishWithStatusSync(const SpanStatus.aborted());
    _request.abort(exception, stackTrace);
  }

  // Delegate all other methods and properties
  @override
  bool get bufferOutput => _request.bufferOutput;

  @override
  set bufferOutput(bool value) => _request.bufferOutput = value;

  @override
  int get contentLength => _request.contentLength;

  @override
  set contentLength(int value) => _request.contentLength = value;

  @override
  Encoding get encoding => _request.encoding;

  @override
  set encoding(Encoding value) => _request.encoding = value;

  @override
  bool get followRedirects => _request.followRedirects;

  @override
  set followRedirects(bool value) => _request.followRedirects = value;

  @override
  int get maxRedirects => _request.maxRedirects;

  @override
  set maxRedirects(int value) => _request.maxRedirects = value;

  @override
  bool get persistentConnection => _request.persistentConnection;

  @override
  set persistentConnection(bool value) => _request.persistentConnection = value;

  @override
  HttpHeaders get headers => _request.headers;

  @override
  HttpConnectionInfo? get connectionInfo => _request.connectionInfo;

  @override
  List<Cookie> get cookies => _request.cookies;

  @override
  String get method => _request.method;

  @override
  Uri get uri => _request.uri;

  @override
  void add(List<int> data) => _request.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _request.addError(error, stackTrace);

  @override
  Future<Object> addStream(Stream<List<int>> stream) =>
      _request.addStream(stream);

  @override
  Future<HttpClientResponse> get done async {
    try {
      final HttpClientResponse response = await _request.done;
      await _finishWithStatus(
        SpanStatus.fromHttpStatusCode(response.statusCode),
      );
      return response;
    } catch (e) {
      _span?.throwable = e;
      await _finishWithStatus(const SpanStatus.internalError());
      rethrow;
    }
  }

  @override
  Future<Object> flush() => _request.flush();

  @override
  void write(Object? object) => _request.write(object);

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) =>
      _request.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => _request.writeCharCode(charCode);

  @override
  void writeln([Object? object = '']) => _request.writeln(object);
}
