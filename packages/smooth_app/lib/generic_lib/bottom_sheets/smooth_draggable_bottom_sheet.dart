import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class SmoothDraggableBottomSheet extends StatefulWidget {
  const SmoothDraggableBottomSheet({
    super.key,
    required this.headerBuilder,
    required this.headerHeight,
    required this.bodyBuilder,
    required this.borderRadius,
    this.initHeightFraction = 0.5,
    this.maxHeightFraction = 1.0,
    this.animationController,
    this.bottomSheetColor,
    this.draggableScrollableController,
  }) : assert(maxHeightFraction > 0.0 && maxHeightFraction <= 1.0);

  final double initHeightFraction;
  final double maxHeightFraction;
  final WidgetBuilder headerBuilder;
  final double headerHeight;
  final WidgetBuilder bodyBuilder;
  final DraggableScrollableController? draggableScrollableController;
  final AnimationController? animationController;
  final BorderRadiusGeometry borderRadius;
  final Color? bottomSheetColor;

  @override
  SmoothDraggableBottomSheetState createState() =>
      SmoothDraggableBottomSheetState();
}

class SmoothDraggableBottomSheetState
    extends State<SmoothDraggableBottomSheet> {
  late final DraggableScrollableController _controller;

  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.draggableScrollableController ?? DraggableScrollableController();
    widget.animationController?.addStatusListener(_animationStatusListener);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.bottomSheetColor ??
        Theme.of(context).bottomSheetTheme.backgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;
    final double bottomPaddingHeight = MediaQuery.paddingOf(context).bottom;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: _scrolling,
      child: Column(
        children: <Widget>[
          Expanded(
            child: SafeArea(
              bottom: false,
              child: DraggableScrollableSheet(
                minChildSize: 0.0,
                maxChildSize: widget.maxHeightFraction,
                initialChildSize: widget.initHeightFraction,
                snap: true,
                controller: _controller,
                builder: (BuildContext context, ScrollController controller) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                      color: backgroundColor,
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: ClipRRect(
                        borderRadius: widget.borderRadius,
                        child: _SmoothDraggableContent(
                          bodyBuilder: widget.bodyBuilder,
                          headerBuilder: widget.headerBuilder,
                          headerHeight: widget.headerHeight,
                          currentExtent: _controller.isAttached
                              ? _controller.size
                              : widget.initHeightFraction,
                          scrollController: controller,
                          cacheExtent: _calculateCacheExtent(
                            MediaQuery.viewInsetsOf(context).bottom,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (bottomPaddingHeight > 0)
            SizedBox(
              width: double.infinity,
              height: bottomPaddingHeight,
              child: ColoredBox(color: backgroundColor),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.animationController?.removeStatusListener(_animationStatusListener);
    super.dispose();
  }

  // Method will be called when scrolling.
  bool _scrolling(DraggableScrollableNotification notification) {
    if (_isClosing) {
      return false;
    }

    if (notification.extent <= 0.005) {
      _isClosing = true;
      Navigator.of(context).maybePop();
    }

    return false;
  }

  // Method that listens for changing AnimationStatus, to track the closing of
  // the bottom sheet by clicking above it.
  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.reverse ||
        status == AnimationStatus.dismissed) {
      _isClosing = true;
    }
  }

  double _calculateCacheExtent(double bottomInset) {
    const double defaultExtent = RenderAbstractViewport.defaultCacheExtent;
    if (bottomInset > defaultExtent) {
      return bottomInset;
    } else {
      return defaultExtent;
    }
  }
}

class _SmoothDraggableContent extends StatefulWidget {
  const _SmoothDraggableContent({
    required this.currentExtent,
    required this.scrollController,
    required this.cacheExtent,
    required this.headerHeight,
    required this.headerBuilder,
    required this.bodyBuilder,
  });

  final WidgetBuilder headerBuilder;
  final double headerHeight;
  final WidgetBuilder bodyBuilder;
  final double currentExtent;
  final ScrollController scrollController;
  final double cacheExtent;

  @override
  State<_SmoothDraggableContent> createState() =>
      _SmoothDraggableContentState();
}

class _SmoothDraggableContentState extends State<_SmoothDraggableContent> {
  final GlobalKey<State<StatefulWidget>> _contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: widget.scrollController,
      child: ChangeNotifierProvider<ScrollController>.value(
        value: widget.scrollController,
        child: CustomScrollView(
          cacheExtent: widget.cacheExtent,
          key: _contentKey,
          controller: widget.scrollController,
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverHeader(
                child: widget.headerBuilder(context),
                height: widget.headerHeight,
              ),
            ),
            widget.bodyBuilder(context),
          ],
        ),
      ),
    );
  }
}

/// A fixed header
class _SliverHeader extends SliverPersistentHeaderDelegate {
  _SliverHeader({
    required this.child,
    required this.height,
  }) : assert(height > 0.0);

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context, _, __) {
    // Align is mandatory here (a known-bug in the framework)
    return Align(child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SliverHeader oldDelegate) => oldDelegate.height != height;
}
