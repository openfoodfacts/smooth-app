
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePageModel extends ChangeNotifier {

  ProfilePageModel() {
    _loadData();
  }

  Future<bool> _loadData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    useMlKit = sharedPreferences.getBool('useMlKit') ?? true;

    notifyListeners();
    return true;
  }

  SharedPreferences sharedPreferences;

  bool useMlKit = true;

  void setMlKitState(bool state) {
    if(sharedPreferences != null) {
      sharedPreferences.setBool('useMlKit', state);
      useMlKit = state;
      notifyListeners();
    }
  }

}