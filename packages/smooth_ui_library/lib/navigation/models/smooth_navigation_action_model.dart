import 'package:flutter/widgets.dart';

class SmoothNavigationActionModel {
  SmoothNavigationActionModel(
      {@required this.icon, @required this.iconPadding, @required this.iconSize, @required this.title, @required this.onTap});

  String icon;
  double iconPadding;
  double iconSize;
  String title;
  Function onTap;
}
