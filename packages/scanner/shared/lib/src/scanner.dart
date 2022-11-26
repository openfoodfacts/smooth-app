import 'package:flutter/foundation.dart';
import 'package:scanner_shared/scanner_shared.dart';

/// Export the [CameraImage] class
export 'package:camera/camera.dart';

/// Base class for MLKit, ZXing and other scanners
abstract class CameraScanner with CameraScannerLogMixin {
  Future<void> onInit({
    required CameraDescription camera,
    required DevModeScanMode mode,
  });

  Future<List<String?>?> processImage(dynamic image) {
    assert(isInitialized, 'onInit() must be called before _onNewImage()');

    if (image is CameraImage && supportCameraImage) {
      return onNewCameraImage(image);
    } else if (image is String && supportCameraFile) {
      return onNewCameraFile(image);
    } else {
      throw Exception('Unsupported image type: $image');
    }
  }

  @protected
  Future<List<String?>?> onNewCameraImage(CameraImage image);

  @protected
  Future<List<String?>?> onNewCameraFile(String path);

  bool get supportCameraImage;

  bool get supportCameraFile;

  bool get isInitialized;

  /// When the device is in low memory mode
  void onLowMemory() {}

  Future<void> onPause() async {}

  Future<void> onResume() async {}

  @mustCallSuper
  Future<void> onDispose() async => disposeLogs();

  @protected
  Stream<CameraScannerLog> listenToLogs() => controller;
}
