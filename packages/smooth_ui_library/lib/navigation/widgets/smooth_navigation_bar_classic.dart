import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_state_model.dart';
import 'package:smooth_ui_library/navigation/widgets/smooth_navigation_button.dart';

class SmoothNavigationBarClassic extends StatefulWidget {
  const SmoothNavigationBarClassic(
      {@required this.color,
      @required this.shadowColor,
      @required this.scanButtonColor,
      @required this.scanShadowColor,
      @required this.scanIconColor,
      @required this.borderRadius,
      @required this.buttons,
      @required this.actionSvgIcons,
      @required this.actions,
      this.animationCurve,
      this.animationDuration,
      this.reverseLayout = false});

  final Color color;
  final Color shadowColor;
  final Color scanButtonColor;
  final Color scanShadowColor;
  final Color scanIconColor;
  final double borderRadius;
  final List<SmoothNavigationButton> buttons;
  final List<String> actionSvgIcons;
  final List<Function> actions;
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
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4.0,
              sigmaY: 4.0,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 68.0,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(widget.borderRadius)),
                color: widget.color,
              ),
              child: Consumer<SmoothNavigationStateModel>(
                builder: (BuildContext context,
                    SmoothNavigationStateModel smoothNavigationStateModel,
                    Widget child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: List<Widget>.generate(
                            (widget.buttons.length / 2).floor(),
                            (int i) {
                              if (smoothNavigationStateModel.currentIndex ==
                                  i) {
                                return Column(
                                  children: <Widget>[
                                    widget.buttons[i],
                                    SmoothRevealAnimation(
                                      child: Text(
                                        widget.buttons[i].title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                      ),
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
                                    Text(
                                      widget.buttons[i].title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 10.0),
                                    )
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                        Row(
                          children: List<Widget>.generate(
                            widget.buttons.length -
                                (widget.buttons.length / 2).floor(),
                            (int i) {
                              if (smoothNavigationStateModel.currentIndex ==
                                  i + (widget.buttons.length / 2).floor()) {
                                return Column(
                                  children: <Widget>[
                                    widget.buttons[i +
                                        (widget.buttons.length / 2).floor()],
                                    SmoothRevealAnimation(
                                      child: Text(
                                        widget
                                            .buttons[i +
                                                (widget.buttons.length / 2)
                                                    .floor()]
                                            .title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                      ),
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
                                    widget.buttons[i +
                                        (widget.buttons.length / 2).floor()],
                                    Text(
                                      widget
                                          .buttons[i +
                                              (widget.buttons.length / 2)
                                                  .floor()]
                                          .title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 10.0,
                                          ),
                                    )
                                  ],
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Consumer<SmoothNavigationStateModel>(
          builder: (BuildContext context,
              SmoothNavigationStateModel smoothNavigationStateModel,
              Widget child) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0.0, -20.0),
                    child: GestureDetector(
                      child: Material(
                        elevation: 12.0,
                        shadowColor: widget.scanShadowColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(60.0)),
                        child: Hero(
                          tag: 'action_button',
                          child: Container(
                            width: 56.0,
                            height: 56.0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(60.0)),
                              color: widget.scanButtonColor,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                widget.actionSvgIcons[
                                    smoothNavigationStateModel.currentIndex],
                                width: 24.0,
                                height: 24.0,
                                color: widget.scanIconColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        if (widget.actions[
                                smoothNavigationStateModel.currentIndex] !=
                            null) {
                          widget.actions[
                              smoothNavigationStateModel.currentIndex]();
                        }
                        ;
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
