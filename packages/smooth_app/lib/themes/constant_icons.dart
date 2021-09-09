// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConstantIcons {
  static bool _isApple() =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static IconData getShareIcon() =>
      _isApple() ? CupertinoIcons.square_arrow_up : Icons.share;

  static IconData getBackIcon() =>
      _isApple() ? CupertinoIcons.back : Icons.arrow_back;
}
