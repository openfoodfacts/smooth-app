import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

/// The [ThemeData] doesn't expose all fields for a floating [SnackBar].
/// Hence this widget…
class SmoothFloatingSnackbar extends SnackBar {
  const SmoothFloatingSnackbar({
    required super.content,
    super.backgroundColor,
    super.elevation,
    super.padding,
    super.width,
    super.shape,
    super.hitTestBehavior,
    super.action,
    super.actionOverflowThreshold,
    super.showCloseIcon,
    super.closeIconColor,
    super.animation,
    super.onVisible,
    super.dismissDirection,
    super.clipBehavior = Clip.hardEdge,
    Duration? duration,
    super.key,
  }) : super(
          margin: const EdgeInsetsDirectional.all(SMALL_SPACE),
          duration: duration ??
              (action != null
                  ? const Duration(seconds: 10)
                  : SnackBarDuration.short),
          behavior: SnackBarBehavior.floating,
        );
}
