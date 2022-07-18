import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Container to display the main product image on a product card.
class SmoothProductImageContainer extends StatelessWidget {
  const SmoothProductImageContainer({
    required this.height,
    required this.width,
    required this.child,
  });

  final double height;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      );
}
