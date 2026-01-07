import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/homepage/homepage.dart';

abstract class HomePageSearchBarBottomWidget {
  Color get color;

  double get height;

  Widget build(BuildContext context);
}

class HomePageHeaderBottomWidgetWrapper extends StatelessWidget {
  const HomePageHeaderBottomWidgetWrapper({required this.child});

  final HomePageSearchBarBottomWidget? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return EMPTY_WIDGET;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(HomePage.BORDER_RADIUS),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: child!.color,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(HomePage.BORDER_RADIUS),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: HomePage.BORDER_RADIUS * 0.5,
          ),
          child: SizedBox.expand(child: child!.build(context)),
        ),
      ),
    );
  }
}
