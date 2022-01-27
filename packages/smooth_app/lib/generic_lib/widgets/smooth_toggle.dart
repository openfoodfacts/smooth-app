import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class SmoothToggle extends StatefulWidget {
  const SmoothToggle({
    this.value = false,
    this.textRight = 'Off',
    this.textLeft = 'On',
    this.textSize = 14.0,
    this.colorRight = Colors.red,
    this.colorLeft = Colors.green,
    required this.iconRight,
    required this.iconLeft,
    this.animationDuration = const Duration(milliseconds: 320),
    this.onTap,
    this.onDoubleTap,
    this.onSwipe,
    required this.onChanged,
    this.width = 150.0,
    this.height = 50.0,
  });

  final bool value;
  final Function(bool) onChanged;
  final String textRight;
  final String textLeft;
  final Color colorRight;
  final Color colorLeft;
  final double textSize;
  final Duration animationDuration;
  final Widget iconRight;
  final Widget iconLeft;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSwipe;
  final double width;
  final double height;

  @override
  State<SmoothToggle> createState() => _SmoothToggleState();
}

class _SmoothToggleState extends State<SmoothToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  double value = 0.0;

  late bool turnState;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: widget.animationDuration,
    );
    animation = CurvedAnimation(
        parent: animationController, curve: Curves.easeInOutBack);
    animationController.addListener(() {
      setState(() {
        value = animation.value;
      });
    });
    turnState = widget.value;
    _determine();
  }

  @override
  Widget build(BuildContext context) {
    final Color transitionColor =
        Color.lerp(widget.colorRight, widget.colorLeft, value)!;

    return GestureDetector(
      onDoubleTap: () {
        _action();
        if (widget.onDoubleTap != null) {
          widget.onDoubleTap!();
        }
      },
      onTap: () {
        _action();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onPanEnd: (DragEndDetails details) {
        _action();
        if (widget.onSwipe != null) {
          widget.onSwipe!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        width: widget.width,
        decoration: BoxDecoration(
            color: transitionColor, borderRadius: BorderRadius.circular(50)),
        child: Stack(
          children: <Widget>[
            //Text right
            Transform.translate(
              offset: Offset(10 * value, 0), //original
              child: Opacity(
                opacity: (1 - value).clamp(0.0, 1.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    height: widget.height - 10,
                    width: widget.width - 40,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        widget.textRight,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.textSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //Text left
            Transform.translate(
              offset: Offset(10 * (1 - value), 0), // not original
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    height: widget.height - 10,
                    width: widget.width - 40,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        widget.textLeft,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.textSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //Pointer
            Transform.translate(
              offset: Offset((widget.width - widget.height) * value, 0),
              child: Transform.rotate(
                angle: lerpDouble(0, 2 * pi, value)!,
                child: Container(
                  height: widget.height - 10,
                  width: widget.height - 10,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Opacity(
                            opacity: (1 - value).clamp(0.0, 1.0),
                            child: widget.iconRight),
                      ),
                      Center(
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: widget.iconLeft,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _action() {
    _determine(changeState: true);
  }

  void _determine({bool changeState = false}) {
    setState(() {
      if (changeState) {
        turnState = !turnState;
      }
      turnState ? animationController.forward() : animationController.reverse();
      widget.onChanged(turnState);
    });
  }
}
