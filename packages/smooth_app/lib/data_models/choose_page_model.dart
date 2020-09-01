import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';

class ChoosePageModel extends ChangeNotifier {
  ChoosePageModel() {
    scrollController.addListener(() {
      if (scrollController.offset < 60.0) {
        opacity = scrollController.offset / 60.0;
        appBarColor = Colors.white.withOpacity(opacity);
        preventAppBarColorRefresh = false;
        notifyListeners();
      } else if (!preventAppBarColorRefresh) {
        preventAppBarColorRefresh = true;
        appBarColor = Colors.white;
        notifyListeners();
      }
    });
  }

  List<Color> colors = <Color>[
    Colors.deepPurpleAccent,
    Colors.deepOrangeAccent,
    Colors.blueAccent,
    Colors.brown,
    Colors.redAccent,
    Colors.lightGreen,
    Colors.amber,
    Colors.indigoAccent,
    Colors.pink
  ];

  PnnsGroup1 selectedCategory;
  Color selectedColor;
  Color appBarColor = Colors.transparent;
  double opacity = 0.0;
  bool preventAppBarColorRefresh = false;

  ScrollController scrollController = ScrollController();

  void selectCategory(PnnsGroup1 group, Color color) {
    selectedCategory = group;
    selectedColor = color;
    notifyListeners();
  }

  void unSelectCategory() {
    if (selectedCategory != null) {
      selectedCategory = null;
      selectedColor = null;
      notifyListeners();
      scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 280), curve: Curves.easeIn);
    }
  }

  Future<bool> onWillPop() async {
    if (selectedCategory != null) {
      unSelectCategory();
      return false;
    } else {
      return true;
    }
  }

  // Icons are from project noun, made by Vectors Market, requires attribution
  String getCategoryIcon(PnnsGroup1 group) {
    switch (group) {
      case PnnsGroup1.BEVERAGES:
        return 'beverages.svg';
        break;
      case PnnsGroup1.CEREALS_AND_POTATOES:
        return 'cereals_and_potatoes.svg';
        break;
      case PnnsGroup1.COMPOSITE_FOODS:
        return 'composite_foods.svg';
        break;
      case PnnsGroup1.FAT_AND_SAUCES:
        return 'fat_and_sauces.svg';
        break;
      case PnnsGroup1.FISH_MEAT_AND_EGGS:
        return 'fish_meat_and_eggs.svg';
        break;
      case PnnsGroup1.FRUITS_AND_VEGETABLES:
        return 'fruits_and_vegetables.svg';
        break;
      case PnnsGroup1.MILK_AND_DAIRIES:
        return 'milk_and_dairies.svg';
        break;
      case PnnsGroup1.SALTY_SNACKS:
        return 'salty_snacks.svg';
        break;
      case PnnsGroup1.SUGARY_SNACKS:
        return 'sugary_snacks.svg';
        break;
      default:
        return null;
        break;
    }
  }
}
