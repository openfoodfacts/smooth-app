import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';

enum SmoothDataCardFormat { SQUARE, WIDE }

class SmoothDataCard extends StatelessWidget {
  const SmoothDataCard({
    required this.content,
    this.width,
    this.height,
    this.color = Colors.white,
    Key? key,
  }) : super(key: key);

  final Widget content;
  final double? width;
  final double? height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SmoothRevealAnimation(
      startOffset: const Offset(0.0, -1.5),
      animationDuration: 500,
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                color: color,
              ),
              padding: const EdgeInsets.all(8.0),
              child: content,
            ),
          )),
    );
  }
}
