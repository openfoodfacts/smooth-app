import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraHelper {
  const CameraHelper._();

  static List<CameraDescription>? _cameras;

  /// Mandatory method to call before [findBestCamera]
  static Future<void> init() async {
    if (!isSupported) {
      _cameras = <CameraDescription>[];
    } else {
      _cameras = await availableCameras();
    }
  }

  /// Returns if the device has more than one camera
  static bool get hasMoreThanOneCamera {
    if (_cameras == null) {
      throw Exception('Please call [init] before!');
    }
    return _cameras!.length > 1;
  }

  /// Returns if the device has at least one camera
  static bool get hasACamera {
    if (_cameras == null) {
      throw Exception('Please call [init] before!');
    } else {
      return _cameras!.isNotEmpty;
    }
  }

  static bool get isSupported => kIsWeb || Platform.isAndroid || Platform.isIOS;
}
