import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/widgets/models/single_boolean_model.dart';

class SmoothExpandableCard extends StatefulWidget {
  const SmoothExpandableCard({
    @required this.collapsedHeader,
    this.expandedHeader,
    @required this.content,
    this.background,
  });

  final Widget collapsedHeader;
  final Widget expandedHeader;
  final Color background;
  final Widget content;
  @override
  _SmoothExpandableCardState createState() => _SmoothExpandableCardState();
}

class _SmoothExpandableCardState extends State<SmoothExpandableCard>
    with SingleTickerProviderStateMixin {
  bool collapsed = true;
  AnimationController _controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    animation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 160),
      crossFadeState: CrossFadeState.showFirst,
      firstChild: _buildCard(),
      secondChild: _buildCard(),
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTap: () {
        print('press1');
        setState(() {
          collapsed = !collapsed;
          animation.value == 0 ? _controller.forward() : _controller.reverse();
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(
            right: 8.0, left: 8.0, top: 4.0, bottom: 20.0),
        child: Material(
          elevation: 8.0,
          shadowColor: Colors.black45,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: widget.background ?? Theme.of(context).colorScheme.surface,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: collapsed
                            ? widget.expandedHeader
                            : widget.collapsedHeader),
                    AnimatedBuilder(
                      animation: animation,
                      child: const Icon(Icons.keyboard_arrow_down),
                      builder: (BuildContext context, Widget child) {
                        return Transform.rotate(
                          angle: animation.value,
                          child: child,
                        );
                      },
                    ),
                  ],
                ),
                if (collapsed == true) widget.content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
