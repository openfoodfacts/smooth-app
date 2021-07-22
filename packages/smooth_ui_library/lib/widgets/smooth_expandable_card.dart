import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_ui_library/animations/smooth_animated_collapse_arrow.dart';

class SmoothExpandableCard extends StatefulWidget {
  const SmoothExpandableCard({
    required this.collapsedHeader,
    required this.child,
    this.expandedHeader,
    this.color,
    this.padding =
        const EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0, bottom: 20.0),
    this.insets = const EdgeInsets.all(12.0),
    this.initiallyCollapsed = true,
  });

  final Widget collapsedHeader;
  final Widget? expandedHeader;
  final Color? color;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? insets;
  final bool initiallyCollapsed;

  @override
  _SmoothExpandableCardState createState() => _SmoothExpandableCardState();
}

class _SmoothExpandableCardState extends State<SmoothExpandableCard> {
  bool collapsed = true; // to be overridden in initState
  static const Duration _ANIMATION_DURATION = Duration(milliseconds: 160);

  @override
  void initState() {
    collapsed = widget.initiallyCollapsed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: _ANIMATION_DURATION,
      crossFadeState: CrossFadeState.showFirst,
      firstChild: _buildCard(),
      secondChild: _buildCard(),
    );
  }

  Widget _buildCard() {
    final Widget notPadded = Material(
      elevation: 8.0,
      shadowColor: Colors.black45,
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      color: widget.color ?? Theme.of(context).colorScheme.surface,
      child: Container(
        padding: widget.insets,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: collapsed
                      ? widget.collapsedHeader
                      : widget.expandedHeader ?? widget.collapsedHeader,
                ),
                SmoothAnimatedCollapseArrow(
                  duration: _ANIMATION_DURATION,
                  collapsed: collapsed,
                ),
              ],
            ),
            if (collapsed != true) widget.child,
          ],
        ),
      ),
    );
    final Widget padded = widget.padding == null
        ? notPadded
        : Padding(
            padding: widget.padding!,
            child: notPadded,
          );
    return GestureDetector(
      onTap: () {
        setState(() {
          collapsed = !collapsed;
        });
      },
      child: padded,
    );
  }
}
