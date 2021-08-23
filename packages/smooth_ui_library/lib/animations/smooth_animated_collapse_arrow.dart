import 'dart:math';

import 'package:flutter/material.dart';

class SmoothAnimatedCollapseArrow extends StatefulWidget {
  const SmoothAnimatedCollapseArrow({
    required this.collapsed,
    this.duration = const Duration(milliseconds: 160),
    this.curve = Curves.ease,
  });

  final bool collapsed;
  final Duration duration;
  final Curve curve;

  @override
  State<SmoothAnimatedCollapseArrow> createState() =>
      _SmoothAnimatedCollapseArrowState();
}

class _SmoothAnimatedCollapseArrowState
    extends State<SmoothAnimatedCollapseArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    animation = Tween<double>(begin: 0, end: pi)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void animate() {
    if (!widget.collapsed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    animate();

    return AnimatedBuilder(
      animation: animation,
      child: const Icon(Icons.keyboard_arrow_down),
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle: animation.value,
          child: child,
        );
      },
    );
  }
}
