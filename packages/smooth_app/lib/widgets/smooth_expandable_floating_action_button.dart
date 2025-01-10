import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

class SmoothExpandableFloatingActionButton extends StatefulWidget {
  const SmoothExpandableFloatingActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.scrollController,
    required this.onPressed,
    this.shape,
  });

  final Widget icon;
  final Widget label;
  final ScrollController scrollController;
  final ShapeBorder? shape;
  final void Function() onPressed;

  @override
  State<SmoothExpandableFloatingActionButton> createState() =>
      _SmoothExpandableFloatingActionButtonState();
}

class _SmoothExpandableFloatingActionButtonState
    extends State<SmoothExpandableFloatingActionButton> {
  bool _extended = true;
  double prevPixelPosition = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      extendedIconLabelSpacing: _extended ? 10.0 : 0.0,
      extendedPadding: _extended
          ? null
          : const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
      onPressed: widget.onPressed,
      icon: widget.icon,
      label: AnimatedSize(
        alignment: Alignment.centerLeft,
        duration: SmoothAnimationsDuration.brief,
        child: _extended ? widget.label : EMPTY_WIDGET,
      ),
      shape: widget.shape,
    );
  }

  void _scrollListener() {
    if ((prevPixelPosition - widget.scrollController.position.pixels).abs() >
        7.5) {
      final bool maxScrollReached =
          widget.scrollController.position.maxScrollExtent ==
              widget.scrollController.position.pixels;
      final bool scrollUp =
          widget.scrollController.position.userScrollDirection ==
              ScrollDirection.forward;

      setState(() => _extended = maxScrollReached || scrollUp);
    }

    prevPixelPosition = widget.scrollController.position.pixels;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }
}
