import 'package:flutter/widgets.dart';
import 'package:smooth_ui_library/navigation/models/smooth_navigation_screen_model.dart';

class SmoothNavigationLayoutModel extends ChangeNotifier {
  SmoothNavigationLayoutModel(
      {@required this.screens, this.initialScreenIndex = 0}) {
    _currentScreenIndex = initialScreenIndex;
  }

  final List<SmoothNavigationScreenModel> screens;
  final int initialScreenIndex;

  int _currentScreenIndex;

  SmoothNavigationScreenModel get currentScreen {
    return screens[_currentScreenIndex];
  }

  set currentScreenIndex(int index) {
    if (index != _currentScreenIndex && index < screens.length) {
      _currentScreenIndex = index;
      notifyListeners();
    }
  }
}
