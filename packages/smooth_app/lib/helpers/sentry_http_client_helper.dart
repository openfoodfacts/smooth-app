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
  static http.Client createClient() {
    if (AnalyticsHelper.isTracingEnabled) {
      return SentryHttpClient();
    } else {
      return http.Client();
    }
  }

  /// Wraps a dart:io HttpClient with Sentry tracing.
  ///
  /// This is used by HttpOverrides to intercept ALL HTTP requests in the app,
  /// including NetworkImage requests and any direct dart:io HttpClient usage.
  static HttpClient wrapHttpClient(HttpClient client) {
    if (AnalyticsHelper.isTracingEnabled) {
      // Return a custom wrapper that adds Sentry tracing
      return _SentryWrappedHttpClient(client);
    } else {
      return client;
    }
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

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      getUrl(Uri(scheme: 'http', host: host, port: port, path: path));

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      postUrl(Uri(scheme: 'http', host: host, port: port, path: path));

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      putUrl(Uri(scheme: 'http', host: host, port: port, path: path));

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      deleteUrl(Uri(scheme: 'http', host: host, port: port, path: path));

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      headUrl(Uri(scheme: 'http', host: host, port: port, path: path));

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      patchUrl(Uri(scheme: 'http', host: host, port: port, path: path));

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) => openUrl(method, Uri(scheme: 'http', host: host, port: port, path: path));

  Future<HttpClientRequest> _wrapRequest(
    Future<HttpClientRequest> Function() requestFactory,
    Uri url,
    String method,
  ) async {
    // Start a Sentry span for this request
    final ISentrySpan? span = Sentry.getSpan()?.startChild(
      'http.client',
      description: '$method $url',
    );

    try {
      final HttpClientRequest request = await requestFactory();

      // Wrap the request to finish the span when done
      return _SentryWrappedHttpClientRequest(request, span);
    } catch (e) {
      span?.throwable = e;
      span?.status = const SpanStatus.internalError();
      await span?.finish();
      rethrow;
    }
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

  @override
  Future<HttpClientResponse> close() async {
    try {
      final HttpClientResponse response = await _request.close();
      _span?.status = SpanStatus.fromHttpStatusCode(response.statusCode);
      await _span?.finish();
      return response;
    } catch (e) {
      _span?.throwable = e;
      _span?.status = const SpanStatus.internalError();
      await _span?.finish();
      rethrow;
    }
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    _span?.status = const SpanStatus.aborted();
    _span?.finish();
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
      _span?.status = SpanStatus.fromHttpStatusCode(response.statusCode);
      await _span?.finish();
      return response;
    } catch (e) {
      _span?.throwable = e;
      _span?.status = const SpanStatus.internalError();
      await _span?.finish();
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
