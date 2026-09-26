import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/physics.dart';

class SmoothHorizontalList extends StatefulWidget {
  const SmoothHorizontalList({
    required this.itemCount,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemBuilder,
    this.startPadding = 24.0,
    this.endPadding = 24.0,
    this.lastItemBuilder,
    super.key,
  }) : assert(itemWidth > 0),
       assert(itemHeight > 0);

  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final double startPadding;
  final double endPadding;
  final IndexedWidgetBuilder itemBuilder;
  final WidgetBuilder? lastItemBuilder;

  @override
  State<SmoothHorizontalList> createState() => _SmoothHorizontalListState();
}

class _SmoothHorizontalListState extends State<SmoothHorizontalList> {
  ScrollController? _controller;

  @override
  Widget build(BuildContext context) {
    _controller ??= ScrollController();

    final int count =
        widget.itemCount + (widget.lastItemBuilder != null ? 1 : 0);

    return SizedBox(
      height: widget.itemHeight,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: HorizontalSnapScrollPhysics(snapSize: widget.itemWidth),
        itemBuilder: (BuildContext context, int position) {
          final Widget child;
          final double startPadding;
          final double endPadding;

          if (position == count - 1 && widget.lastItemBuilder != null) {
            startPadding = 8.0;
            endPadding = widget.endPadding;
            child = widget.lastItemBuilder!(context);
          } else {
            startPadding = position == 0 ? widget.startPadding : 8.0;
            endPadding = position == count - 1 && widget.lastItemBuilder == null
                ? widget.endPadding
                : 0.0;

            child = widget.itemBuilder(context, position);
          }

          return SizedBox(
            height: widget.itemHeight,
            width: widget.itemWidth + startPadding + endPadding,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: startPadding,
                end: endPadding,
              ),
              child: child,
            ),
          );
        },
        itemCount: count,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
