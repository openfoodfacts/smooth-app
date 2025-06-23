import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/widgets/widget_height.dart';

/// [AnimatedList] only animates insertions and deletions, but not moves.
/// This widget only supports changing the order of items.
class SmoothAnimatedList<T> extends StatefulWidget {
  const SmoothAnimatedList({
    required this.itemBuilder,
    required this.separatorSize,
    required this.data,
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.padding,
    super.key,
  });

  final SmoothSliverListItemBuilder<T> itemBuilder;
  final ChildIndexGetter? findChildIndexCallback;
  final double separatorSize;
  final List<T> data;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final EdgeInsetsDirectional? padding;

  @override
  State<SmoothAnimatedList<T>> createState() => _SmoothAnimatedListState<T>();
}

class _SmoothAnimatedListState<T> extends State<SmoothAnimatedList<T>> {
  final List<int> _hiddenPositions = <int>[];
  final List<OverlayEntry> _floatingItems = <OverlayEntry>[];
  final Map<int, Size> _itemSizes = <int, Size>{};
  List<T> _oldData = <T>[];
  bool _hideOldItems = false;

  @override
  void didUpdateWidget(covariant SmoothAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      if (oldWidget.data.length != widget.data.length) {
        throw Exception(
          'This widget does not support changing the number of items',
        );
      }

      _clearFloatingItems();

      final _DataDiff<T> diff = _DataDiff.computeDiff(
        oldWidget.data,
        widget.data,
      );
      _oldData = oldWidget.data;

      for (final _DataMove<T> move in diff.movedItems) {
        _hiddenPositions.add(move.oldIndex);
        _addFloatingItem(move, _widgetPosition);
      }

      SchedulerBinding.instance.addPostFrameCallback((_) {
        final OverlayState overlay = Overlay.of(context);
        _floatingItems.forEach(overlay.insert);
      });
    }
  }

  Offset get _widgetPosition {
    final RenderBox renderObject =
        context.findRenderObject()!.parent! as RenderBox;

    return renderObject.localToGlobal(Offset.zero);
  }

  void _addFloatingItem(_DataMove<T> move, Offset widgetPosition) {
    final OverlayEntry floatingItem = OverlayEntry(
      builder: (BuildContext context) {
        return _MovingOverlayItem(
          widgetPosition: widgetPosition.translate(
            0.0,
            widget.padding?.top ?? 0.0,
          ),
          startTop:
              (_itemSizes[move.oldIndex]!.height + widget.separatorSize) *
              move.oldIndex,
          endTop:
              (_itemSizes[move.oldIndex]!.height + widget.separatorSize) *
              move.newIndex,
          start: widget.padding?.start ?? 0.0,
          end: widget.padding?.end ?? 0.0,
          child: widget.itemBuilder(context, move.item, move.oldIndex),
          onVisible: () {
            if (!_hideOldItems) {
              setState(() => _hideOldItems = true);
            }
          },
          onAnimationEnd: () {
            _hiddenPositions.remove(move.oldIndex);

            if (_hiddenPositions.isEmpty) {
              _hideOldItems = false;
              _oldData.clear();
              _clearFloatingItems();
              setState(() {});
            }
          },
        );
      },
    );

    _floatingItems.add(floatingItem);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasHiddenItems = _hiddenPositions.isNotEmpty;

    return ListView.separated(
      itemCount: widget.data.length,
      itemBuilder: (BuildContext context, int index) {
        if (hasHiddenItems) {
          final Widget child = widget.itemBuilder(
            context,
            _oldData.elementAt(index),
            index,
          );

          if (_hiddenPositions.contains(index) && _hideOldItems) {
            return Opacity(opacity: 0, child: child);
          } else {
            return child;
          }
        }

        return MeasureSize(
          onChange: (Size size) => _itemSizes[index] = size,
          child: widget.itemBuilder(
            context,
            widget.data.elementAt(index),
            index,
          ),
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: widget.separatorSize),
      findChildIndexCallback: widget.findChildIndexCallback,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      padding: widget.padding,
    );
  }

  void _removeAllFloatingItems() {
    for (final OverlayEntry floatingItem in _floatingItems) {
      floatingItem.remove();
      floatingItem.dispose();
    }
    _floatingItems.clear();
  }

  void _clearFloatingItems() {
    _removeAllFloatingItems();
    _floatingItems.clear();
  }

  @override
  void dispose() {
    _removeAllFloatingItems();
    super.dispose();
  }
}

typedef SmoothSliverListItemBuilder<T> =
    Widget Function(BuildContext context, T object, int index);

class _MovingOverlayItem extends StatefulWidget {
  const _MovingOverlayItem({
    required this.widgetPosition,
    required this.startTop,
    required this.endTop,
    required this.start,
    required this.end,
    required this.child,
    required this.onVisible,
    required this.onAnimationEnd,
  });

  final Offset widgetPosition;
  final double startTop;
  final double endTop;
  final double start;
  final double end;
  final Widget child;
  final VoidCallback onVisible;
  final VoidCallback onAnimationEnd;

  @override
  State<_MovingOverlayItem> createState() => _MovingOverlayItemState();
}

class _MovingOverlayItemState extends State<_MovingOverlayItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double?> _translateAnimation;
  late Animation<double?> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: SmoothAnimationsDuration.medium,
        )..addListener(() {
          if (_translateAnimation.value == widget.endTop) {
            widget.onAnimationEnd();
          }

          setState(() {});
        });

    _translateAnimation =
        Tween<double>(begin: widget.startTop, end: widget.endTop).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.9, curve: Curves.easeInOutQuint),
          ),
        );

    /// A subtle fade will be applied at the end of the animation
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.88, 1.0)),
    );

    /// Start the animation immediately
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onVisible();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      top: widget.widgetPosition.dy + (_translateAnimation.value ?? 0.0),
      start: widget.start,
      end: widget.end,
      textDirection: Directionality.of(context),
      child: Material(
        child: Opacity(
          opacity: _opacityAnimation.value ?? 1.0,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Computes the moves between two lists of data
class _DataDiff<T> {
  _DataDiff._(this.movedItems);

  final List<_DataMove<T>> movedItems;

  static _DataDiff<T> computeDiff<T>(List<T> oldData, List<T> newData) {
    final List<_DataMove<T>> movedItems = <_DataMove<T>>[];

    for (final T item in newData) {
      final int oldPosition = oldData.indexOf(item);
      if (oldPosition != -1) {
        final int newPosition = newData.indexOf(item);
        if (oldPosition != newPosition) {
          movedItems.add(_DataMove<T>(item, oldPosition, newPosition));
        }
      }
    }

    return _DataDiff<T>._(movedItems);
  }
}

class _DataMove<T> {
  _DataMove(this.item, this.oldIndex, this.newIndex);

  final T item;
  final int oldIndex;
  final int newIndex;
}
