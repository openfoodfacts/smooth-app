import 'package:flutter/foundation.dart';
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
    _hasBackCamera = await _hasCamera(front: false);
    _hasFrontCamera = await _hasCamera(front: true);
  }

  /// A failing camera query means "no camera", not a failed app start.
  static Future<bool> _hasCamera({required bool front}) async {
    try {
      return await GlobalVars.barcodeScanner.hasCamera(front: front);
    } catch (_) {
      return false;
    }
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

  static bool get isSupported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
