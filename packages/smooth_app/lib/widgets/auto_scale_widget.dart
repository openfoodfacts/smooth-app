import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A Widget that will animate the change of its child size.
class AutoScaleWidget extends SingleChildRenderObjectWidget {
  const AutoScaleWidget({
    super.key,
    required this.duration,
    required this.vsync,
    super.child,
  });

  final Duration duration;
  final TickerProvider vsync;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _AutoScaleRenderObject(vsync: vsync, duration: duration);
  }
}

class _AutoScaleRenderObject extends RenderProxyBox {
  _AutoScaleRenderObject({
    required TickerProvider vsync,
    required Duration duration,
    RenderBox? child,
  }) : super(child) {
    _controller = AnimationController(vsync: vsync, duration: duration)
      ..addListener(markNeedsLayout);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  Size _childSize = Size.zero;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void performLayout() {
    if (child == null) {
      return super.performLayout();
    }

    final Size? childSize =
        (child?..layout(constraints, parentUsesSize: true))?.size;
    if (childSize != null && childSize.height != _childSize.height) {
      _childSize = childSize;
      _controller.forward();
    }

    size = Size(_childSize.width, _childSize.height * _controller.value);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final int alpha = (_animation.value * 255).clamp(0, 255).toInt();
      context.pushOpacity(offset, alpha, super.paint);
    }
  }

  @override
  void detach() {
    _controller.stop();
    super.detach();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
