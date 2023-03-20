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
          return const CircularProgressIndicator();
        }

        IconData icon;

        switch (snapshot.requireData) {
          case FlashMode.on:
            icon = Icons.flash_on;
            break;
          case FlashMode.none:
            icon = Icons.flash_off;
            break;
          case FlashMode.always:
            icon = Icons.flash_on;
            break;
          case FlashMode.auto:
            icon = Icons.flash_auto;
            break;
          default:
            icon = Icons.abc;
            break;
        }

        if (!snapshot.hasData) {
          return Container();
        }
        return IconButton(
          color: Colors.white,
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          onPressed: () async {
            SmoothHapticFeedback.click();
            if (snapshot.requireData != FlashMode.always) {
              state.sensorConfig.setFlashMode(FlashMode.always);
            } else {
              state.sensorConfig.setFlashMode(FlashMode.none);
            }
          },
        );
      },
    );
  }
}
