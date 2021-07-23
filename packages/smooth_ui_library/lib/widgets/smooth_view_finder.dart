import 'dart:async';

import 'package:flutter/material.dart';

class SmoothViewFinder extends StatefulWidget {
  const SmoothViewFinder({
    required this.width,
    required this.height,
    required this.animationDuration,
    Key? key,
  }) : super(key: key);

  final double width;
  final double height;
  final int animationDuration;

  @override
  State<StatefulWidget> createState() => SmoothViewFinderState();
}

class SmoothViewFinderState extends State<SmoothViewFinder>
    with SingleTickerProviderStateMixin {
  bool goRight = false;
  Timer? animationTimer;

  @override
  void initState() {
    super.initState();

    animationTimer = Timer.periodic(
        Duration(milliseconds: widget.animationDuration), (Timer t) {
      setState(() {
        goRight = !goRight;
      });
    });
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                border: Border.all(color: Colors.white, width: 1.0)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                width: goRight ? 288.0 : 0.0,
                height: widget.height,
                decoration: const BoxDecoration(
                  border: Border(
                      right: BorderSide(
                    width: 1.0,
                    color: Colors.white70,
                  )),
                ),
                duration: Duration(milliseconds: widget.animationDuration),
                curve: Curves.easeInOutCubic,
              ),
            ),
          ),
        ),
        Transform.translate(
            offset: Offset(-widget.width * 0.12, 4.0),
            child: Text(
              'Powered by Open Food Facts',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white),
              textAlign: TextAlign.start,
            )),
      ],
    );
  }
}
