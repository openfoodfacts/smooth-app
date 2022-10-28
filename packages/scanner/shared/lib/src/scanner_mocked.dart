import 'package:scanner_shared/scanner_shared.dart';

/// Empty implementation
/// (for testing or on non-supported platforms like the desktop)
class MockedCameraScanner extends CameraScanner {
  @override
  Future<void> onInit({
    required CameraDescription camera,
    required DevModeScanMode mode,
  }) async {}

  @override
  Future<List<String?>?> onNewCameraFile(String path) async {
    return <String>[];
  }

  @override
  Future<List<String?>?> onNewCameraImage(CameraImage image) async {
    return <String>[];
  }

  @override
  bool get supportCameraFile => true;

  @override
  bool get supportCameraImage => true;

  @override
  bool get isInitialized => true;
}
