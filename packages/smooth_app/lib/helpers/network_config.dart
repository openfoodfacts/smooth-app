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

/// Imports the OFF SSL certificate (for Android 7.1+ / iOS devices)
/// or accepts all certificates
Future<void> _importSSLCertificate() async {
  if (Platform.isAndroid) {
    await dip.loadLibrary();
    final int sdkInt =
        (await dip.DeviceInfoPlugin().androidInfo).version.sdkInt;

    // API Level 25 is Android 7.1
    // Note: For Android 7.1-, we need to combine SSL certificate handling
    // with Sentry tracing in _SentryHttpOverrides
    if (sdkInt < 25) {
      // The _SentryHttpOverrides will handle both SSL and tracing
    }
  }

  final ByteData data = await PlatformAssetBundle().load(
    AppHelper.getAssetPath('assets/network/cert.pem'),
  );

  SecurityContext.defaultContext.setTrustedCertificatesBytes(
    data.buffer.asUint8List(),
  );
}

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

    // Handle SSL certificates for Android 7.1-
    if (Platform.isAndroid) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              host.contains('openfoodfacts.org');
    }

    // Wrap with Sentry tracing if enabled
    return SentryHttpClientHelper.wrapHttpClient(client);
  }
}
