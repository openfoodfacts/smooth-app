import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmoothCard extends StatelessWidget {
  const SmoothCard({
    required this.child,
    this.color,
    this.header,
    this.padding =
        const EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0, bottom: 4.0),
    this.insets = const EdgeInsets.all(5.0),
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final Color? color;
  final Widget? header;
  final EdgeInsets? padding;
  final EdgeInsets? insets;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final Widget result = Material(
      elevation: 8.0,
      clipBehavior: clipBehavior,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(10.0),
      color: color ?? Theme.of(context).colorScheme.surface,
      child: Container(
        padding: insets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (header != null) header!,
            child,
          ],
        ),
      ),
    );
    if (padding == null) {
      return result;
    }
    return Padding(
      padding: padding!,
      child: result,
    );
  }
}
