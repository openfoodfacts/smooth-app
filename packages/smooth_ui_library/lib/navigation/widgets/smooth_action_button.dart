import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        child: Material(
            elevation: 24.0,
            shadowColor: shadowColor.withAlpha(160),
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 4.0,
                  sigmaY: 4.0,
                ),
                child: Container(
                  width: 220.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius)),
                    color: color,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        height: 50.0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(action.iconPadding),
                            child: SvgPicture.asset(
                              action.icon,
                              width: action.iconSize,
                              height: action.iconSize,
                            ),
                          ),
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
                                    fontWeight: FontWeight.bold,
                                    color: textColor),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
