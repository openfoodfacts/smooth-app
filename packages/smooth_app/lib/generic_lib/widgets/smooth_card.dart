import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Renders a Material card with elevation, shadow, Border radius etc...
/// Note: If the caller updates BoxDecoration of the [header] or [child] widget,
/// the caller must also set the borderRadius to [ROUNDED_RADIUS] in
/// BoxDecoration.
/// Note: [padding] applies to both header and body, if you want to have a
/// padding only for body and not for header (or vice versa) set it to zero here
/// and set the padding explicitly in the desired element.
class SmoothCard extends StatelessWidget {
  const SmoothCard({
    required this.child,
    this.color,
    this.margin = const EdgeInsets.symmetric(
      horizontal: SMALL_SPACE,
      vertical: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 8.0,
    this.borderRadius,
    this.ignoreDefaultSemantics = false,
    this.clipBehavior,
  });

  const SmoothCard.angular({
    required this.child,
    this.color,
    this.margin = const EdgeInsets.symmetric(
      horizontal: SMALL_SPACE,
      vertical: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 8.0,
    this.ignoreDefaultSemantics = false,
    this.clipBehavior,
  }) : borderRadius = ANGULAR_BORDER_RADIUS;

  const SmoothCard.flat({
    required this.child,
    this.color,
    this.margin = const EdgeInsetsDirectional.only(
      start: SMALL_SPACE,
      end: SMALL_SPACE,
      top: VERY_SMALL_SPACE,
      bottom: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 0.0,
    this.borderRadius,
    this.ignoreDefaultSemantics = false,
    this.clipBehavior,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double elevation;
  final bool ignoreDefaultSemantics;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (padding != null) {
      result = Padding(
        padding: padding!,
        child: result,
      );
    }

    if (ignoreDefaultSemantics) {
      result = Semantics(
        container: false,
        explicitChildNodes: true,
        child: child,
      );
    }

    result = Material(
      elevation: elevation,
      shadowColor: const Color.fromARGB(25, 0, 0, 0),
      borderRadius: borderRadius ?? ROUNDED_BORDER_RADIUS,
      color: color ??
          (Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black),
      clipBehavior: clipBehavior ?? Clip.none,
      child: result,
    );

    return margin == null
        ? result
        : Padding(
            padding: margin!,
            child: result,
          );
  }
}
