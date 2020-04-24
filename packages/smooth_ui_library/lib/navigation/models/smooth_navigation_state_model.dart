
import 'package:flutter/widgets.dart';

enum SmoothNavigationBarState {
  OPEN,
  CLOSE
}

class SmoothNavigationStateModel extends ChangeNotifier {

  bool _isExpanded = false;
  int _currentIndex;

  SmoothNavigationBarState get state {
    if(_isExpanded) {
      return SmoothNavigationBarState.OPEN;
    } else {
      return SmoothNavigationBarState.CLOSE;
    }
  }

  int get currentIndex {
    if(_currentIndex != null) {
      return _currentIndex;
    } else {
      return 0;
    }
  }

  void open() {
    if(!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  void close() {
    if(_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }

  set currentIndex(int i) {
    if(i != _currentIndex) {
      _currentIndex = i;
      notifyListeners();
    }
  }

}