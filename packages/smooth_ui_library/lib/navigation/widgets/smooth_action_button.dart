import 'package:flutter/material.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_action_model.dart';

class SmoothActionButton extends StatelessWidget {
  const SmoothActionButton(
      {@required this.action,
      this.borderRadius = 60.0,
      @required this.color,
      @required this.textColor,
      @required this.shadowColor});

  final SmoothNavigationActionModel action;
  final double borderRadius;
  final Color color;
  final Color textColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        action.onTap();
      },
      child: Container(
        width: 220.0,
        height: 60.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          color: color,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: 16.0,
              offset: const Offset(4.0, 4.0),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: 50.0,
              height: 50.0,
              child: Center(
                child: action.icon,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Material(
                    color: Colors.transparent,
                    child: Text(
                      action.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: textColor),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
