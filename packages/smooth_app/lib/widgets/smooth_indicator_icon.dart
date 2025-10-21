import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// A circle icon (generally used to show an action)
class SmoothIndicatorIcon extends StatelessWidget {
  const SmoothIndicatorIcon({
    required this.icon,
    this.iconTheme,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.customBorder,
    super.key,
  });

  final Widget icon;
  final IconThemeData? iconTheme;
  final Color? backgroundColor;
  final ShapeBorder? customBorder;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsetsDirectional.all(VERY_SMALL_SPACE),
      child: Material(
        color: backgroundColor ?? Colors.black38,
        shape: customBorder ?? const CircleBorder(),
        child: Padding(
          padding: padding ?? const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: IconTheme(
            data:
                iconTheme ??
                const IconThemeData(color: Colors.white, size: 15.0),
            child: icon,
          ),
        ),
      ),
    );
  }
}
