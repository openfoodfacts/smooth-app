import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConstantIcons {
  @visibleForTesting
  const ConstantIcons();

  static ConstantIcons get instance => _instance ??= const ConstantIcons();
  static ConstantIcons? _instance;

  /// Setter that allows tests to override the singleton instance.
  @visibleForTesting
  static set instance(ConstantIcons testInstance) => _instance = testInstance;

  static bool _isApple() =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  IconData getShareIcon() =>
      _isApple() ? CupertinoIcons.square_arrow_up : Icons.share;

  IconData getBackIcon() => _isApple() ? CupertinoIcons.back : Icons.arrow_back;

  IconData getForwardIcon() =>
      _isApple() ? CupertinoIcons.forward : Icons.arrow_forward;

  IconData getCameraFlip() =>
      _isApple() ? Icons.flip_camera_ios : Icons.flip_camera_android;
}
