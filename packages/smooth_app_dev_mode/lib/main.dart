import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/main.dart' as smooth;

void main() {
  if (kReleaseMode) {
    smooth.main();
  } else {
    smooth.main(appBuilder: (BuildContext context) {
      return DevicePreview(
        builder: (_) => const smooth.SmoothApp(),
      );
    });
  }
}
