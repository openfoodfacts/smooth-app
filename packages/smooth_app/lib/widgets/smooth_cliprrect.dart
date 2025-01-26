import 'package:flutter/material.dart';

class SmoothClipRRect extends StatelessWidget {
  const SmoothClipRRect({
    required this.child,
    this.enabled = true,
    this.borderRadius = BorderRadius.zero,
    this.clipBehavior = Clip.antiAlias,
    this.clipper,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
  final CustomClipper<RRect>? clipper;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      clipper: clipper,
      child: child,
    );
  }
}
