import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_state_model.dart';
import 'package:smooth_ui_library/navigation/widgets/smooth_navigation_button.dart';

class SmoothNavigationBarClassic extends StatefulWidget {
  const SmoothNavigationBarClassic(
      {@required this.color,
      @required this.shadowColor,
      @required this.borderRadius,
      @required this.buttons,
      this.animationCurve,
      this.animationDuration,
      this.reverseLayout = false});

  final Color color;
  final Color shadowColor;
  final double borderRadius;
  final List<SmoothNavigationButton> buttons;
  final Curve animationCurve;
  final int animationDuration;
  final bool reverseLayout;

  @override
  State<StatefulWidget> createState() => _SmoothNavigationBarClassicState();
}

class _SmoothNavigationBarClassicState extends State<SmoothNavigationBarClassic>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 24.0,
        shadowColor: widget.shadowColor.withAlpha(160),
        color: Colors.transparent,
        borderRadius: BorderRadius.only(topRight: Radius.circular(widget.borderRadius), topLeft: Radius.circular(widget.borderRadius)),
        child: ClipRRect(
            borderRadius:
                BorderRadius.all(Radius.circular(widget.borderRadius)),
            child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 4.0,
                  sigmaY: 4.0,
                ),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 75.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(widget.borderRadius)),
                      color: widget.color,
                    ),
                    child: Consumer<SmoothNavigationStateModel>(builder:
                        (BuildContext context,
                            SmoothNavigationStateModel
                                smoothNavigationStateModel,
                            Widget child) {
                      return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List<Widget>.generate(
                            widget.buttons.length,
                            (int i) {
                              if (smoothNavigationStateModel.currentIndex ==
                                  i) {
                                return Column(
                                  children: <Widget>[
                                    widget.buttons[i],
                                    SmoothRevealAnimation(
                                      child: Text(widget.buttons[i].title, style: Theme.of(context)
                                          .textTheme
                                          .bodyText1.copyWith(color: Colors.black, fontWeight: FontWeight.w500),),
                                      animationCurve: widget.animationCurve,
                                      animationDuration:
                                          widget.animationDuration,
                                      startOffset: const Offset(0.0, 1.0),
                                    )
                                  ],
                                );
                              } else {
                                return Column(
                                  children: <Widget>[
                                    widget.buttons[i],
                                    Text(widget.buttons[i].title, style: Theme.of(context)
                                          .textTheme
                                          .bodyText1.copyWith(color: Colors.black54, fontWeight: FontWeight.normal),
                                    )
                                  ],
                                );
                              }
                            },
                          ));
                    })))));
  }
}
