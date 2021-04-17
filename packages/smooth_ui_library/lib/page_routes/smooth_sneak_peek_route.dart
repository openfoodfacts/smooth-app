import 'package:flutter/material.dart';

class SmoothSneakPeekRoute<T> extends PageRoute<T> {
  SmoothSneakPeekRoute({required this.builder, this.duration = 200});

  final WidgetBuilder builder;
  final int duration;

  @override
  bool get opaque => false;

  @override
  Color get barrierColor => Colors.black26;

  @override
  String get barrierLabel => 'Closed sneak peek';

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: duration);
}
