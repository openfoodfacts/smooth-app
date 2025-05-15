import 'package:flutter/material.dart';

class AppBarBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          bottom: 0.0,
          start: 0.0,
          width: 240.0,
          height: 240.0,
          child: Transform.translate(
            offset: const Offset(-100.0, 40.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white10,
                  width: 10.0,
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: 0.0,
          end: 0.0,
          width: 220.0,
          height: 220.0,
          child: Transform.translate(
            offset: const Offset(80.0, -40.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white10,
                  width: 10.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
