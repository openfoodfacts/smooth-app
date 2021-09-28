import 'package:flutter/material.dart';

class SmoothCard extends StatelessWidget {
  const SmoothCard({
    required this.child,
    this.color,
    this.header,
    this.margin =
        const EdgeInsets.only(right: 8.0, left: 8.0, top: 4.0, bottom: 4.0),
    this.padding = const EdgeInsets.all(5.0),
  });

  final Widget child;
  final Color? color;
  final Widget? header;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  static const Radius CIRCULAR_RADIUS = Radius.circular(10.0);

  @override
  Widget build(BuildContext context) {
    final Widget result = Material(
      elevation: 8.0,
      shadowColor: Colors.black45,
      borderRadius: const BorderRadius.all(CIRCULAR_RADIUS),
      color: color ?? Theme.of(context).colorScheme.surface,
      child: Container(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (header != null) header!,
            child,
          ],
        ),
      ),
    );
    return margin == null
        ? result
        : Padding(
            padding: margin!,
            child: result,
          );
  }
}
