library smooth_ui_library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_state_model.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_layout_model.dart';
import 'package:smooth_ui_library/navigation/widgets/smooth_action_button.dart';
import 'package:smooth_ui_library/navigation/widgets/smooth_navigation_bar.dart';
import 'package:smooth_ui_library/navigation/widgets/smooth_navigation_button.dart';

class SmoothNavigationLayout extends StatelessWidget {
  const SmoothNavigationLayout(
      {@required this.layout,
      this.borderRadius = 60.0,
      this.color = Colors.white,
      this.textColor = Colors.black,
      this.shadowColor = Colors.black45,
      this.animationCurve = Curves.fastLinearToSlowEaseIn,
      this.animationDuration = 400,
      this.reverseLayout = false})
      : assert(borderRadius >= 0.0);

  final SmoothNavigationLayoutModel layout;
  final double borderRadius;
  final Color color;
  final Color textColor;
  final Color shadowColor;
  final Curve animationCurve;
  final int animationDuration;
  final bool reverseLayout;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SmoothNavigationLayoutModel>(
      create: (BuildContext context) => layout,
      child: Stack(
        children: <Widget>[
          _getBottomLayer(),
          _getTopLayer(),
        ],
      ),
    );
  }

  Widget _getBottomLayer() {
    return Consumer<SmoothNavigationLayoutModel>(
      builder: (BuildContext context, SmoothNavigationLayoutModel layout,
          Widget child) {
        return layout.currentScreen.page;
      },
    );
  }

  Widget _getTopLayer() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 40.0),
          child: ChangeNotifierProvider<SmoothNavigationStateModel>(
            create: (BuildContext context) => SmoothNavigationStateModel(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _getLayout(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _getLayout() {
    if(reverseLayout) {
      return <Widget>[
        _getNavigationBar(),
        _getActionButton()
      ];
    }

    return <Widget>[
      _getActionButton(),
      _getNavigationBar()
    ];
  }

  Widget _getActionButton() {
    return Consumer<SmoothNavigationStateModel>(builder:
        (BuildContext context,
        SmoothNavigationStateModel smoothNavigationStateModel,
        Widget child) {
      if (layout.screens[smoothNavigationStateModel.currentIndex]
          .action !=
          null) {
        return SmoothActionButton(
          borderRadius: borderRadius,
          color: color,
          textColor: textColor,
          shadowColor: shadowColor,
          action: layout
              .screens[smoothNavigationStateModel.currentIndex]
              .action,
        );
      } else {
        return Container();
      }
    });
  }

  Widget _getNavigationBar() {
    return SmoothNavigationBar(
      color: color,
      shadowColor: shadowColor,
      borderRadius: borderRadius,
      buttons: List<SmoothNavigationButton>.generate(
          layout.screens.length, (int i) {
        return SmoothNavigationButton(
          icon: layout.screens[i].icon,
          index: i,
        );
      }),
      animationCurve: animationCurve,
      animationDuration: animationDuration,
    );
  }
}
