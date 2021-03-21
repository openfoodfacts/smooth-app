import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmoothCard extends StatelessWidget {
  const SmoothCard({
    @required this.content,
    this.background,
    this.header,
  });

  final Widget content;
  final Color background;
  final Widget header;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            right: 8.0, left: 8.0, top: 4.0, bottom: 20.0),
        child: Material(
          elevation: 8.0,
          shadowColor: Colors.black45,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: background ?? Theme.of(context).colorScheme.surface,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                header ?? Container(),
                content,
              ],
            ),
          ),
        ),
      );
}
