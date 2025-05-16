import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

/// A custom [InteractiveViewer] with a double-tap zoom in/out animation.
class SmoothInteractiveViewer extends StatefulWidget {
  const SmoothInteractiveViewer({
    required this.child,
    this.interactionEndFrictionCoefficient,
    this.minScale,
    this.maxScale,
    super.key,
  });

  final Widget child;
  final double? interactionEndFrictionCoefficient;
  final double? minScale;
  final double? maxScale;

  @override
  State<SmoothInteractiveViewer> createState() =>
      _SmoothInteractiveViewerState();
}

class _SmoothInteractiveViewerState extends State<SmoothInteractiveViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Matrix4> _animation;

  final TransformationController _transformationController =
      TransformationController();

  late TapDownDetails _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addListener(() {
        _transformationController.value = _animation.value;
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        interactionEndFrictionCoefficient:
            widget.interactionEndFrictionCoefficient ?? 0.0000135,
        maxScale: widget.maxScale ?? 2.5,
        minScale: widget.minScale ?? 0.8,
        transformationController: _transformationController,
        child: widget.child,
      ),
    );
  }

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _onDoubleTap() {
    Matrix4 matrix;
    // Reset zoom
    if (_transformationController.value != Matrix4.identity()) {
      matrix = Matrix4.identity();
      _animationController.duration = const Duration(milliseconds: 300);
    } else {
      // Zoom x2
      final Offset position = _doubleTapDetails.localPosition;
      matrix = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
      _animationController.duration = SmoothAnimationsDuration.short;
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeInCubic).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }
}
