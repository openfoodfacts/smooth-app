import 'package:flutter/material.dart' hide Listener;
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

class RobotoffSuggestionListItemButton extends StatefulWidget {
  const RobotoffSuggestionListItemButton({
    required this.icon,
    required this.padding,
    required this.tooltip,
    required this.onTap,
    required this.visible,
  });

  final Widget icon;
  final EdgeInsetsGeometry padding;
  final String tooltip;
  final VoidCallback onTap;
  final bool visible;

  @override
  State<RobotoffSuggestionListItemButton> createState() =>
      _RobotoffSuggestionListItemButtonState();
}

class _RobotoffSuggestionListItemButtonState
    extends State<RobotoffSuggestionListItemButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            duration: SmoothAnimationsDuration.short,
            vsync: this,
          )
          ..addListener(() => setState(() {}))
          ..value = widget.visible ? 1.0 : 0.0;

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void didUpdateWidget(RobotoffSuggestionListItemButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.visible != widget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animation.value == 0.0) {
      return EMPTY_WIDGET;
    }

    return SizedBox.square(
      dimension: 40.0 * _animation.value,
      child: FittedBox(
        child: Tooltip(
          message: widget.tooltip,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            child: Opacity(
              opacity: _animation.value,
              child: Padding(padding: widget.padding, child: widget.icon),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
