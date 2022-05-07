import 'package:camera/camera.dart';

class CameraHelper {
  const CameraHelper._();

  static List<CameraDescription>? _cameras;

  /// Mandatory method to call before [findBestCamera]
  static Future<void> init() async {
    _cameras = await availableCameras();
  }

  /// Find the most relevant camera to use if none of these criteria are met,
  /// the default value of [_cameraIndex] will be used to select the first
  /// camera in the global cameras list.
  /// if non matching is found we fall back to the first in the list
  /// initValue of [_cameraIndex]/
  static CameraDescription? findBestCamera({
    CameraLensDirection cameraLensDirection = CameraLensDirection.back,
  }) {
    if (_cameras == null) {
      throw Exception('Please call [init] before!');
    } else if (_cameras!.isEmpty) {
      return null;
    }

    int cameraIndex = -1;

    if (_cameras!.any(
      (CameraDescription element) =>
          element.lensDirection == cameraLensDirection &&
          element.sensorOrientation == 90,
    )) {
      cameraIndex = _cameras!.indexOf(
        _cameras!.firstWhere((CameraDescription element) =>
            element.lensDirection == cameraLensDirection &&
            element.sensorOrientation == 90),
      );
    } else if (_cameras!.any((CameraDescription element) =>
        element.lensDirection == cameraLensDirection)) {
      cameraIndex = _cameras!.indexOf(
        _cameras!.firstWhere(
          (CameraDescription element) =>
              element.lensDirection == cameraLensDirection,
        ),
      );
    }

    return _cameras![cameraIndex];
  }
}
