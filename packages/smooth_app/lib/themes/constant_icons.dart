import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConstantIcons {
  const ConstantIcons._();

  static bool _isApple() =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static IconData get shareIcon =>
      _isApple() ? CupertinoIcons.square_arrow_up : Icons.share;

  static IconData get backIcon =>
      _isApple() ? CupertinoIcons.back : Icons.arrow_back;

  static IconData get forwardIcon =>
      _isApple() ? CupertinoIcons.forward : Icons.arrow_forward;

  static IconData get cameraFlip =>
      _isApple() ? Icons.flip_camera_ios : Icons.flip_camera_android;
}
