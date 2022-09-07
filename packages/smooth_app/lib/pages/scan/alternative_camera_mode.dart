import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// File based camera implementation (only on Android)
class AlternativeCameraMode {
  const AlternativeCameraMode._();

  static final Iterable<String> _whitelistedBrands = <String>{
    'OnePlus',
  };
  static final Iterable<String> _whitelistedModels = <String>{
    'CPH2409', // OnePlus Nord CE 2 Lite 5G
  };

  static bool get isSupported => Platform.isAndroid;

  /// Detects if the current device is whitelisted for the "alternative" mode
  static Future<bool> get isAWhitelistedDevice async {
    if (!isSupported) {
      return false;
    }

    return DeviceInfoPlugin().androidInfo.then(
          (AndroidDeviceInfo info) =>
              _whitelistedBrands.contains(info.brand) ||
              _whitelistedModels.contains(info.model),
        );
  }

  static Future<String> getDeviceName() {
    if (!isSupported) {
      throw UnsupportedError('Not supported on this platform');
    }

    return DeviceInfoPlugin().androidInfo.then(
          (AndroidDeviceInfo info) => '${info.brand} / ${info.model}',
        );
  }
}
