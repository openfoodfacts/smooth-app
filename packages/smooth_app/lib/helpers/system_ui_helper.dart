import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class SystemUIStyle {
  const SystemUIStyle._();

  static const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle light = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
}
