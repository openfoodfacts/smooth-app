import 'dart:io';

import 'package:mobile_scanner/mobile_scanner.dart';

class CameraHelper {
  const CameraHelper._();

  static Set<CameraLensType>? _cameraLensTypesBack;
  static Set<CameraLensType>? _cameraLensTypesFront;

  /// Mandatory method to call.
  static Future<void> init() async {
    if (!isSupported) {
      _cameraLensTypesBack = <CameraLensType>{};
      _cameraLensTypesFront = <CameraLensType>{};
      return;
    }
    _cameraLensTypesBack = await MobileScannerPlatform.instance
        .getSupportedLenses(facing: CameraFacing.back);
    _cameraLensTypesFront = await MobileScannerPlatform.instance
        .getSupportedLenses(facing: CameraFacing.front);
  }

  /// Returns if the device has more than one camera
  static bool get hasMoreThanOneCamera {
    if (_cameraLensTypesBack == null) {
      throw Exception('Please call [init] before!');
    }
    return _cameraLensTypesBack!.isNotEmpty &&
        _cameraLensTypesFront!.isNotEmpty;
  }

  /// Returns if the device has at least one camera
  static bool get hasACamera {
    if (_cameraLensTypesBack == null) {
      throw Exception('Please call [init] before!');
    }
    return _cameraLensTypesBack!.isNotEmpty ||
        _cameraLensTypesFront!.isNotEmpty;
  }

  static bool get isSupported => Platform.isAndroid || Platform.isIOS;
}
