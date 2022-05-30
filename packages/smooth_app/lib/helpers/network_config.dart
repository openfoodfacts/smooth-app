import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart' deferred as dip;
import 'package:flutter/services.dart';
import 'package:openfoodfacts/model/UserAgent.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Initializes both the user agent && the SSL certificate
Future<void> setupAppNetworkConfig() async {
  await _initUserAgent();
  return _importSSLCertificate();
}

Future<void> _initUserAgent() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'Smoothie - ${packageInfo.appName}',
    version: '${packageInfo.version}+${packageInfo.buildNumber}',
    system: Platform.operatingSystemVersion,
    url: 'https://world.openfoodfacts.org/',
  );
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
    'assets/network/cert.pem',
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
