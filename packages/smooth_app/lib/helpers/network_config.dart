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

  final String name = 'Smoothie - ${packageInfo.appName}';
  final String version = '${packageInfo.version}+${packageInfo.buildNumber}';
  final String system =
      '${Platform.operatingSystem}+${Platform.operatingSystemVersion}';
  final String comment = _getAppInfoComment(
    name: name,
    version: version,
    system: system,
  );
  OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: name,
      version: version,
      system: system,
      url: 'https://world.openfoodfacts.org/',
      comment: comment);
}

String _getAppInfoComment({
  bool withName = true,
  String name = '',
  bool withVersion = true,
  String version = '',
  bool withSystem = true,
  String system = '',
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
  return appInfo;
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
