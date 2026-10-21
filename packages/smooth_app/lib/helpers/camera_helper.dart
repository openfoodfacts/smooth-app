import 'dart:io';

import 'package:smooth_app/helpers/global_vars.dart';

class CameraHelper {
  const CameraHelper._();

  static bool? _hasBackCamera;
  static bool? _hasFrontCamera;

  /// Mandatory method to call.
  static Future<void> init() async {
    if (!isSupported) {
      _hasBackCamera = false;
      _hasFrontCamera = false;
      return;
    }
    _hasBackCamera = await GlobalVars.barcodeScanner.hasCamera(front: false);
    _hasFrontCamera = await GlobalVars.barcodeScanner.hasCamera(front: true);
  }

  /// Returns if the device has more than one camera
  static bool get hasMoreThanOneCamera {
    if (_hasBackCamera == null) {
      throw Exception('Please call [init] before!');
    }
    return _hasBackCamera! && _hasFrontCamera!;
  }

  /// Returns if the device has at least one camera
  static bool get hasACamera {
    if (_hasBackCamera == null) {
      throw Exception('Please call [init] before!');
    }
    return _hasBackCamera! || _hasFrontCamera!;
  }

  static bool get isSupported => Platform.isAndroid || Platform.isIOS;
}
