import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';

/// Renders a Material card with elevation, shadow, Border radius etc...
/// Note: If the caller updates BoxDecoration of the [header] or [child] widget,
/// the caller must also set the borderRadius to [CIRCULAR_RADIUS] in
/// BoxDecoration.
/// Note: [padding] applies to both header and body, if you want to have a
/// padding only for body and not for header (or vice versa) set it to zero here
/// and set the padding explicitly in the desired element.
class SmoothCard extends StatelessWidget {
  const SmoothCard({
    required this.child,
    this.color,
    this.header,
    this.margin = const EdgeInsets.only(
      right: SMALL_SPACE,
      left: SMALL_SPACE,
      top: VERY_SMALL_SPACE,
      bottom: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 8,
  });

  final Widget child;
  final Color? color;
  final Widget? header;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double elevation;

  static const Radius CIRCULAR_RADIUS = Radius.circular(10.0);

  @override
  Widget build(BuildContext context) {
    final Widget result = Material(
      elevation: elevation,
      shadowColor: Colors.black45,
      borderRadius: const BorderRadius.all(CIRCULAR_RADIUS),
      color: color ?? Theme.of(context).colorScheme.surface,
      child: Container(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (header != null) header!,
            child,
          ],
        ),
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
