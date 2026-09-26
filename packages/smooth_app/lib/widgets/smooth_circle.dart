import 'package:flutter/cupertino.dart';

/// A rounded background (useful for icons, etc.)
class SmoothCircle extends StatelessWidget {
  const SmoothCircle({
    required this.padding,
    required this.color,
    required this.child,
    super.key,
  });

  SmoothCircle.indicator({
    required this.color,
    required double size,
    this.padding = EdgeInsetsDirectional.zero,
  }) : assert(size > 0.0),
       child = SizedBox.square(dimension: size);

  final EdgeInsetsGeometry padding;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Padding(padding: padding, child: child),
    );
  }
}
