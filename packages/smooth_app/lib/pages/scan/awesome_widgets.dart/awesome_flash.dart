import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';

class SmoothAwesomeFlashButton extends StatelessWidget {
  const SmoothAwesomeFlashButton({
    super.key,
    required this.state,
  });
  final CameraState state;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FlashMode>(
      stream: state.sensorConfig.flashMode$,
      builder: (BuildContext context, AsyncSnapshot<FlashMode> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return IconButton(
          color: Colors.white,
          icon: snapshot.requireData == FlashMode.on
              ? const Icon(
                  Icons.flash_on,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.flash_off,
                  color: Colors.white,
                ),
          onPressed: () async {
            SmoothHapticFeedback.click();
            state.sensorConfig.switchCameraFlash();
          },
        );
      },
    );
  }
}
