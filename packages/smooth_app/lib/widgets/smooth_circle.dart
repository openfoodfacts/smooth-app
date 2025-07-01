import 'package:flutter/cupertino.dart';

/// A rounded background (useful for icons, etc.)
class SmoothCircle extends StatelessWidget {
  const SmoothCircle({
    required this.padding,
    required this.color,
    required this.child,
    super.key,
  });

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
