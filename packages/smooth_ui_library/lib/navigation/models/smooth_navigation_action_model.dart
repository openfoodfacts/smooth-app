import 'package:flutter/widgets.dart';

class SmoothNavigationActionModel {
  SmoothNavigationActionModel(
      {@required this.icon, @required this.title, @required this.onTap});

  Widget icon;
  String title;
  Function onTap;
}
