import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart' deferred as dip;
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/sentry_http_client_helper.dart';
import 'package:uuid/uuid.dart';

/// Initializes both the user agent && the SSL certificate
Future<void> setupAppNetworkConfig() async {
  await _initUserAgent();
  _initHttpOverrides();
  return _importSSLCertificate();
}

/// Initializes HTTP overrides with Sentry tracing support.
///
/// This sets up a custom HttpOverrides that intercepts ALL HTTP requests
/// (including NetworkImage, http.get, etc.) and conditionally enables
/// Sentry tracing based on user consent.
void _initHttpOverrides() {
  HttpOverrides.global = _SentryHttpOverrides();
}

String _getUuidId() {
  if (OpenFoodAPIConfiguration.uuid != null) {
    return OpenFoodAPIConfiguration.uuid!;
  }

  const Uuid uuid = Uuid();
  OpenFoodAPIConfiguration.uuid = uuid.v4();
  return OpenFoodAPIConfiguration.uuid!;
}

Future<void> _initUserAgent() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  final String name = 'Smoothie - ${packageInfo.appName}';
  final String version = '${packageInfo.version}+${packageInfo.buildNumber}';
  final String system =
      '${Platform.operatingSystem}+${Platform.operatingSystemVersion}';
  final String id = _getUuidId();
  final String comment = _getAppInfoComment(
    name: name,
    version: version,
    system: system,
    id: id,
  );
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: name,
    version: version,
    system: system,
    url: 'https://world.openfoodfacts.org/',
    comment: comment,
  );
}

String _getAppInfoComment({
  bool withName = true,
  String name = '',
  bool withVersion = true,
  String version = '',
  bool withSystem = true,
  String system = '',
  bool withId = true,
  String id = '',
}) {
  String appInfo = '';
  const String infoDelimiter = ' - ';
  if (withName) {
    appInfo += infoDelimiter;
    appInfo += name;
  }
  if (withVersion) {
    appInfo += infoDelimiter;
    appInfo += version;
  }
  if (withSystem) {
    appInfo += infoDelimiter;
    appInfo += system;
  }
  if (withId) {
    appInfo += infoDelimiter;
    appInfo += id;
  }
  return appInfo;
}

/// Cached Android SDK int for use in sync [HttpOverrides.createHttpClient].
/// Null on non-Android or before [_importSSLCertificate] has run.
int? _cachedAndroidSdkInt;

/// Imports the OFF SSL certificate (for Android 7.1+ / iOS devices)
/// or accepts all certificates
Future<void> _importSSLCertificate() async {
  if (Platform.isAndroid) {
    await dip.loadLibrary();
    final int sdkInt =
        (await dip.DeviceInfoPlugin().androidInfo).version.sdkInt;
    _cachedAndroidSdkInt = sdkInt;
  }

  final ByteData data = await PlatformAssetBundle().load(
    AppHelper.getAssetPath('assets/network/cert.pem'),
  );

  SecurityContext.defaultContext.setTrustedCertificatesBytes(
    data.buffer.asUint8List(),
  );
}

/// Returns true for trusted OFF hosts.
///
/// Previously checked with `host.contains('openfoodfacts.org')`, which also
/// matched `evil-openfoodfacts.org` or `openfoodfacts.org.evil.com`.
bool _isTrustedOFFHost(String host) =>
    host == 'openfoodfacts.org' || host.endsWith('.openfoodfacts.org');

/// Custom HttpOverrides that combines SSL certificate handling with Sentry tracing.
///
/// This intercepts ALL HTTP requests in the app, including:
/// - NetworkImage requests
/// - http.get/post/etc calls
/// - Any dart:io HttpClient usage
///
/// It wraps the HttpClient with Sentry tracing when user has opted in.
class _SentryHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context);

    // Only for Android 7.1 and below (API <25) fall back to permissive
    // callback for OFF hosts. Modern Android uses default validation +
    // the custom CA added via setTrustedCertificatesBytes.
    // _cachedAndroidSdkInt is set during _importSSLCertificate; before that
    // (early HttpClients) default to strict validation (null => 25).
    if (Platform.isAndroid && (_cachedAndroidSdkInt ?? 25) < 25) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              _isTrustedOFFHost(host);
    }

    // Wrap with Sentry tracing if enabled
    return SentryHttpClientHelper.wrapHttpClient(client);
  }
}
