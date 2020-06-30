
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmoothUploadModel extends ChangeNotifier {

  String frontPath;
  String ingredientsPath;
  String nutritionPath;

  void setFrontPath(String path) {
    frontPath = path;
    notifyListeners();
  }

  void setIngredientsPath(String path) {
    ingredientsPath = path;
    notifyListeners();
  }

  void setNutritionPath(String path) {
    nutritionPath = path;
    notifyListeners();
  }

}