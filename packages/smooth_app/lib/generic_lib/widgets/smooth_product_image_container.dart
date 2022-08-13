import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Container to display the main product image on a product card.
class SmoothProductImageContainer extends StatelessWidget {
  const SmoothProductImageContainer({
    this.child,
    this.height,
    this.width,
    this.color,
  });

  final Widget? child;
  final double? height;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: Container(
          width: width,
          height: height,
          color: color,
          child: child,
        ),
      );
}
