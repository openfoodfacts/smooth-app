import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

const Widget EMPTY_WIDGET = SizedBox.shrink();

extension VisibilityInfoExt on VisibilityInfo {
  bool get visible => visibleBounds.height > 0.0;
}
