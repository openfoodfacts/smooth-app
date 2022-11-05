import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:scanner_shared/scanner_shared.dart';

class ZXingCameraScanner extends CameraScanner {
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('openfoodfacts/zxing');

  CameraDescription? _camera;

  @override
  Future<void> onInit({
    required CameraDescription camera,
    required DevModeScanMode mode,
  }) async {
    _camera = camera;
  }

  @override
  Future<List<String?>?> onNewCameraFile(String path) async {
    assert(path.isNotEmpty);

    return methodChannel.invokeMethod<String>('scanFile', <String, dynamic>{
      'path': path,
      'orientation': _camera!.sensorOrientation,
    }).then((String? value) {
      return value != null ? <String>[value] : null;
    });
  }

  @override
  Future<List<String?>?> onNewCameraImage(CameraImage image) async {
    throw UnimplementedError();
  }

  @override
  bool get isInitialized => _camera != null;

  @override
  bool get supportCameraFile => true;

  @override
  bool get supportCameraImage => false;
}
