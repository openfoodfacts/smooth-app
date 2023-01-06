import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart' deferred as dip;
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Initializes both the user agent && the SSL certificate
Future<void> setupAppNetworkConfig() async {
  await _initUserAgent();
  return _importSSLCertificate();
}

Future<void> _initUserAgent() async {
  try {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final String name = 'Smoothie - ${packageInfo.appName}';
    final String version = '${packageInfo.version}+${packageInfo.buildNumber}';
    final String system =
        '${Platform.operatingSystem}+${Platform.operatingSystemVersion}';

    // Setting no comment here as this will be overridden at runtime
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: name,
      version: version,
      system: system,
      url: 'https://world.openfoodfacts.org/',
    );
  } catch (e) {
    Logs.e('Failed to set user agent $e');
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'Smoothie (error)',
      version: '',
      system:
          'isAndroid: ${Platform.isAndroid}, isIOS: ${Platform.isIOS}, error: $e',
      url: 'https://world.openfoodfacts.org/',
    );
  }
}

/// Imports the OFF SSL certificate (for Android 7.1+ / iOS devices)
/// or accepts all certificates
Future<void> _importSSLCertificate() async {
  if (Platform.isAndroid) {
    await dip.loadLibrary();
    final int sdkInt =
        (await dip.DeviceInfoPlugin().androidInfo).version.sdkInt ?? 1;

    // API Level 25 is Android 7.1
    if (sdkInt < 25) {
      HttpOverrides.global = _AndroidHttpOverrides();
    }
  }

  final ByteData data = await PlatformAssetBundle().load(
    AppHelper.getAssetPath('assets/network/cert.pem'),
  );

  SecurityContext.defaultContext.setTrustedCertificatesBytes(
    data.buffer.asUint8List(),
  );
}

/// A custom Http implementation that accepts all SSL certificates
class _AndroidHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              host.contains('openfoodfacts.org');
  }
}
