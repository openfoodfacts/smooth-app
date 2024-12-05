import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class SmoothCloseButton extends StatelessWidget {
  const SmoothCloseButton({
    required this.onClose,
    required this.circleColor,
    required this.crossColor,
    required this.tooltip,
    this.padding,
    this.circleSize = 28.0,
    this.crossSize = 14.0,
    super.key,
  }) : assert(tooltip.length > 0);

  final VoidCallback onClose;
  final Color circleColor;
  final Color crossColor;
  final String tooltip;
  final EdgeInsetsGeometry? padding;
  final double? circleSize;
  final double? crossSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onClose,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
              child: Ink(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
                padding: const EdgeInsetsDirectional.all(7.0),
                child: icons.Close(
                  size: crossSize,
                  color: crossColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
