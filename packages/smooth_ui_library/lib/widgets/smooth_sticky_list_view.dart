import 'package:flutter/material.dart';

typedef HasSameHeader = bool Function(int a, int b);

class SmoothStickyListView extends StatefulWidget {
  const SmoothStickyListView(
      {Key? key,
      required this.itemCount,
      required this.itemExtend,
      required this.headerBuilder,
      required this.itemBuilder,
      required this.hasSameHeader,
      this.padding,
      this.headerPadding})
      : super(key: key);

  final int itemCount;
  final IndexedWidgetBuilder headerBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsets? padding;
  final EdgeInsets? headerPadding;
  final HasSameHeader hasSameHeader;
  final double itemExtend;

  @override
  State<SmoothStickyListView> createState() => _SmoothStickyListViewState();
}

class _SmoothStickyListViewState extends State<SmoothStickyListView> {
  int currentPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView.builder(
            padding: widget.padding,
            itemCount: widget.itemCount,
            itemExtent: widget.itemExtend,
            controller: _getScrollController(),
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                children: <Widget>[
                  Expanded(child: widget.itemBuilder(context, index)),
                  FittedBox(
                    child: Opacity(
                      opacity: _shouldShowHeader(index) ? 1.0 : 0.0,
                      child: widget.headerBuilder(context, index),
                    ),
                  ),
                ],
              );
            }),
        Positioned(
          child: Opacity(
            opacity: _shouldShowHeader(currentPosition) ? 0.0 : 1.0,
            child: widget.headerBuilder(
                context, currentPosition >= 0 ? currentPosition : 0),
          ),
          top: 0.0 + (widget.headerPadding?.top ?? 0),
          left: 0.0 + (widget.headerPadding?.left ?? 0),
        ),
      ],
    );
  }

  bool _shouldShowHeader(int position) {
    if (position < 0) {
      return true;
    }
    if (position == 0 && currentPosition < 0) {
      return true;
    }

    if (position != 0 &&
        position != currentPosition &&
        !widget.hasSameHeader(position, position - 1)) {
      return true;
    }

    if (position != widget.itemCount - 1 &&
        !widget.hasSameHeader(position, position + 1) &&
        position == currentPosition) {
      return true;
    }
    return false;
  }

  ScrollController _getScrollController() {
    final ScrollController controller = ScrollController();
    controller.addListener(() {
      final double pixels = controller.offset;
      final int newPosition = (pixels / widget.itemExtend).floor();

      if (newPosition != currentPosition) {
        setState(() {
          currentPosition = newPosition;
        });
      }
    });
    return controller;
  }
}
