import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:smooth_app/pages/scan/camera_controller.dart';

class CameraHelper {
  const CameraHelper._();

  static final CameraControllerNotifier _cameraControllerWrapper =
      CameraControllerNotifier();

  static List<CameraDescription>? _cameras;

  /// Mandatory method to call before [findBestCamera]
  static Future<void> init() async {
    _cameras = await availableCameras();
  }

  /// Returns if the device has at least one camera
  static bool get hasACamera {
    if (_cameras == null) {
      throw Exception('Please call [init] before!');
    } else {
      return _cameras!.isNotEmpty;
    }
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

  /// Init the controller
  /// And prevents the redefinition of it
  static void initController(SmoothCameraController controller) {
    _cameraControllerWrapper._updateController(controller);
  }

  static void destroyControllerInstance() {
    _cameraControllerWrapper._updateController(null);
  }

  static SmoothCameraController? get controller =>
      _cameraControllerWrapper._controller;

  /// Subscribe to this notifier to know when the controller is created /
  /// destroyed
  static CameraControllerNotifier get cameraControllerNotifier =>
      _cameraControllerWrapper;
}

/// Custom implementation to prevent the use of a [ValueNotifier] which may be
/// limited in some case (@see [_updateController] below)
class CameraControllerNotifier extends ChangeNotifier {
  SmoothCameraController? _controller;

  void _updateController(SmoothCameraController? controller) {
    try {
      _controller = controller;
      // Always call [notifyListeners] even if the value is similar
      notifyListeners();
    } catch (err) {
      // If no Widget listens to us, an error may be thrown here
    }
  }
}
