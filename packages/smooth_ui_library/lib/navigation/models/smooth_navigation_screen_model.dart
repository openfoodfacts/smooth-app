import 'package:flutter/widgets.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_action_model.dart';

class SmoothNavigationScreenModel {
  SmoothNavigationScreenModel(
      {@required this.page,
      @required this.icon,
      this.action,
      this.alternativeOnPress});

  Widget page;
  Widget icon;
  SmoothNavigationActionModel action;
  Function alternativeOnPress;
}
