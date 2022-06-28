import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/pages/scan/camera_controller.dart';

/// Forked Widget from the [camera] library, but with a simpler Widget
class CameraStreamPreview extends StatelessWidget {
  const CameraStreamPreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final SmoothCameraController? controller = CameraHelper.controller;

    if (controller == null || !controller.isInitialized) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: _isLandscape()
          ? controller.value.aspectRatio
          : (1.0 / controller.value.aspectRatio),
      child: _wrapInRotatedBox(
        child: controller.buildPreview(),
      ),
    );
  }

  Widget _wrapInRotatedBox({
    required Widget child,
  }) {
    if (Platform.isIOS) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ].contains(_getApplicableOrientation());
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller!.value.isRecordingVideo
        ? controller!.value.recordingOrientation!
        : (controller!.value.previewPauseOrientation ??
            controller!.value.lockedCaptureOrientation ??
            controller!.value.deviceOrientation);
  }

  SmoothCameraController? get controller => CameraHelper.controller;
}
