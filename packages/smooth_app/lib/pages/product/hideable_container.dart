import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

class HideableContainer extends StatefulWidget {
  const HideableContainer({required this.child, super.key});

  final Widget child;

  @override
  State<HideableContainer> createState() => HideableContainerState();
}

class HideableContainerState extends State<HideableContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween<double> _tween;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // hidable

    _tween = Tween<double>(begin: 1.0, end: 0.0);

    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.medium,
    );

    _animation = _tween.animate(_controller)
      ..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Provider<HideableContainerState>.value(
      value: this,
      child: Transform.translate(
        offset: Offset(0.0, (1 - _animation.value) * 100),
        child: Opacity(opacity: _animation.value, child: widget.child),
      ),
    );
  }

  void hide(VoidCallback onAnimationEnded) {
    _controller.forward(from: 0.0);
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        onAnimationEnded();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static HideableContainerState of(BuildContext context) {
    return context.read<HideableContainerState>();
  }
}
