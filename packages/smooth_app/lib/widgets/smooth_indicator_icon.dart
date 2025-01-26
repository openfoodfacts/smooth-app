import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// A circle icon (generally used to show an action)
class SmoothIndicatorIcon extends StatelessWidget {
  const SmoothIndicatorIcon({
    required this.icon,
    this.iconTheme,
    this.margin,
    this.padding,
    super.key,
  });

  final Widget icon;
  final IconThemeData? iconTheme;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          const EdgeInsetsDirectional.all(
            VERY_SMALL_SPACE,
          ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: IconTheme(
            data: iconTheme ??
                const IconThemeData(
                  color: Colors.white,
                  size: 15.0,
                ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
