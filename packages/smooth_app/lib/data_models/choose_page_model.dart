
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChoosePageModel extends ChangeNotifier {

  Map<String, Color> categories = <String, Color> {
    'Category 1' : Colors.deepPurpleAccent,
    'Category 2' : Colors.deepOrangeAccent,
    'Category 3' : Colors.blueAccent,
    'Category 4' : Colors.brown,
    'Category 5' : Colors.redAccent,
    'Category 6' : Colors.blueGrey,
    'Category 7' : Colors.amber,
    'Category 8' : Colors.indigoAccent,
    'Category 9' : Colors.pink,
  };

  Map<String, List<String>> subCategories = <String, List<String>> {
    'Category 1' : <String>['Category 1 : sub 1', 'Category 1 : sub 2', 'Category 1 : sub 3', 'Category 1 : sub 4',],
    'Category 2' : <String>['Category 2 : sub 1', 'Category 2 : sub 2',],
    'Category 3' : <String>['Category 3 : sub 1', 'Category 3 : sub 2', 'Category 3 : sub 3', 'Category 3 : sub 4',],
    'Category 4' : <String>['Category 4 : sub 1', 'Category 4 : sub 2', 'Category 4 : sub 3',],
    'Category 5' : <String>['Category 5 : sub 1', 'Category 5 : sub 2',],
    'Category 6' : <String>['Category 6 : sub 1', 'Category 6 : sub 2', 'Category 6 : sub 3', 'Category 6 : sub 4', 'Category 6 : sub 5',],
    'Category 7' : <String>['Category 7 : sub 1', 'Category 7 : sub 2', 'Category 7 : sub 3',],
    'Category 8' : <String>['Category 8 : sub 1', 'Category 8 : sub 2', 'Category 8 : sub 3', 'Category 8 : sub 4'],
    'Category 9' : <String>['Category 9 : sub 1',],
  };

  String selectedCategory;

  void selectCategory(String key) {
    selectedCategory = key;
    notifyListeners();
  }

  void unSelectCategory() {
    if(selectedCategory != null) {
      selectedCategory = null;
      notifyListeners();
    }
  }

}