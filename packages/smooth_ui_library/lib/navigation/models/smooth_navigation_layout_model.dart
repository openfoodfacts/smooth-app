import 'package:flutter/widgets.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_screen_model.dart';

enum SmoothNavigationLayoutState { EXPANDED, COLLAPSED }

class SmoothNavigationLayoutModel extends ChangeNotifier {
  SmoothNavigationLayoutModel(
      {@required this.screens,
      this.initialState = SmoothNavigationLayoutState.COLLAPSED}) {
    if (initialState == SmoothNavigationLayoutState.EXPANDED) {
      isExpanded = true;
    } else {
      isExpanded = false;
    }

    _currentScreenIndex = 0;
  }

  List<SmoothNavigationScreenModel> screens;
  int initialScreenIndex;
  SmoothNavigationLayoutState initialState;

  bool isExpanded;
  int _currentScreenIndex;

  SmoothNavigationScreenModel get currentScreen {
    return screens[_currentScreenIndex];
  }

  set currentScreenIndex(int index) {
    if (index != _currentScreenIndex) {
      _currentScreenIndex = index;
      notifyListeners();
    }
  }
}
