import 'dart:io';

/// The app supports two camera modes:
/// - The alternative one (or file-based) relying on files
///  * enabled by default
///  * not available on iOS
/// - The old one relying on a list of bytes
///  * only solution available on iOS
class CameraModes {
  const CameraModes._();

  static bool get supportBothModes => Platform.isAndroid;

  static bool get supportFileBasedMode => Platform.isAndroid;

  static bool get supportBytesArrayMode => Platform.isAndroid || Platform.isIOS;

  static CameraMode get defaultCameraMode =>
      supportFileBasedMode ? CameraMode.FILE_BASED : CameraMode.BYTES_ARRAY;
}

enum CameraMode {
  FILE_BASED,
  BYTES_ARRAY,
}
