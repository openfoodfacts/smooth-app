import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/main.dart' as smooth;
import 'package:smooth_app/smooth_app_configuration.dart';

/// Launch app with
/// flutter run -t packages/smooth_app_dev_mode/lib/main.dart
///
/// If you want to disable Device Preview, just add:
/// flutter run -t packages/smooth_app_dev_mode/lib/main.dart --dart-define="DEVICE_PREVIEW=false"
void main() {
  smooth.main(
    appConfiguration: SmoothAppConfiguration(
      fromPackage: true,
      screenshots: false,
      appBuilder: (BuildContext context) {
        return DevicePreview(
          enabled:
              const bool.fromEnvironment('DEVICE_PREVIEW', defaultValue: true),
          builder: (_) => const smooth.SmoothApp(),
        );
      },
    ),
  );
}
