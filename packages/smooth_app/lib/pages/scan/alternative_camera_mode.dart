import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:smooth_app/helpers/collections_helper.dart';

/// File based camera implementation (only on Android)
class AlternativeCameraMode {
  const AlternativeCameraMode._();

  static final Iterable<String> _whitelistedBrands = <String>{
    'OnePlus',
  };

  static final Iterable<_SupportedDevice> _whitelistedModels =
      <_SupportedDevice>{
    // OnePlus Nord CE 2 Lite 5G
    const _SupportedDevice('OnePlus', 'CPH2409'),
    const _SupportedDevice('OPPO', 'CPH2135'),
  };

  static bool get isSupported => Platform.isAndroid;

  /// Detects if the current device is whitelisted for the "alternative" mode
  static Future<bool> get isAWhitelistedDevice async {
    if (!isSupported) {
      return false;
    }

    return DeviceInfoPlugin().androidInfo.then(
          (AndroidDeviceInfo info) =>
              _whitelistedBrands.containsIgnoreCase(info.brand) ||
              _whitelistedModels.contains(
                _SupportedDevice(
                  info.brand ?? '',
                  info.model ?? '',
                ),
              ),
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

class _SupportedDevice {
  const _SupportedDevice(this.brand, this.model);

  final String brand;
  final String model;
}
