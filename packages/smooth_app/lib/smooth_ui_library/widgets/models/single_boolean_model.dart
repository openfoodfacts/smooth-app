import 'package:flutter/widgets.dart';

class SingleBooleanModel extends ChangeNotifier {
  bool isActive = false;

  void setActive() {
    isActive = true;
    notifyListeners();
  }

  void setInactive() {
    isActive = false;
    notifyListeners();
  }
}
