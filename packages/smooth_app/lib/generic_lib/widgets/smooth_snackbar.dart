import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

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

  SmoothFloatingSnackbar.error({
    required BuildContext context,
    required String text,
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
          backgroundColor:
              context.extension<SmoothColorsThemeExtension>().error,
          content: Row(
            children: <Widget>[
              ExcludeSemantics(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 6.0,
                      end: SMALL_SPACE,
                      top: 6.5,
                      bottom: SMALL_SPACE,
                    ),
                    child: Builder(
                      builder: (BuildContext context) {
                        return icons.Warning(
                          color: context
                              .extension<SmoothColorsThemeExtension>()
                              .error,
                          size: 15.0,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: LARGE_SPACE),
              Expanded(
                child: Text(
                  text,
                ),
              ),
            ],
          ),
        );
}
