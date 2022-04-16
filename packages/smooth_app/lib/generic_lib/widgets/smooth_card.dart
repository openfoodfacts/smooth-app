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
    this.margin = const EdgeInsets.only(
      right: SMALL_SPACE,
      left: SMALL_SPACE,
      top: VERY_SMALL_SPACE,
      bottom: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 8,
  });

  const SmoothCard.flat({
    required this.child,
    this.color,
    this.margin = const EdgeInsets.only(
      right: SMALL_SPACE,
      left: SMALL_SPACE,
      top: VERY_SMALL_SPACE,
      bottom: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 0,
  });

  final Widget child;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final Widget result = Material(
      elevation: elevation,
      shadowColor: const Color.fromARGB(25, 0, 0, 0),
      borderRadius: ROUNDED_BORDER_RADIUS,
      color: color ?? Theme.of(context).colorScheme.surface,
      child: Container(
        padding: padding,
        child: child,
      ),
    );
    return margin == null
        ? result
        : Padding(
            padding: margin!,
            child: result,
          );
  }
}
