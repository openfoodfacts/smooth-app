import 'package:flutter/material.dart';
import 'package:smooth_app/pages/food_preferences/pages/allergies_page.dart';
import 'package:smooth_app/pages/food_preferences/pages/diets_page.dart';
import 'package:smooth_app/pages/food_preferences/pages/environment_preferences_page.dart';
import 'package:smooth_app/pages/food_preferences/pages/foods_to_avoid_page.dart';
import 'package:smooth_app/pages/food_preferences/pages/introduction_page.dart';
import 'package:smooth_app/pages/food_preferences/pages/unwanted_foods_page.dart';

enum FoodPreferencesPageType {
  introduction,
  diets,
  allergies,
  unwantedFoods,
  foodsToAvoid,
  environment,
}

class FoodPreferencesController extends ChangeNotifier {
  FoodPreferencesController() {
    _pageController = PageController();
  }

  late final PageController _pageController;

  int _currentPageIndex = 0;

  PageController get pageController => _pageController;

  int get currentPageIndex => _currentPageIndex;
  int get pageCount => pages.length;

  bool get isFirstPage => _currentPageIndex == 0;
  bool get isLastPage => _currentPageIndex == pageCount - 1;
  double get progress => (currentPageIndex + 1) / pageCount;

  static final Map<FoodPreferencesPageType, Widget> pages =
      <FoodPreferencesPageType, Widget>{
        FoodPreferencesPageType.introduction: const IntroductionPage(),
        FoodPreferencesPageType.diets: const DietsPage(),
        FoodPreferencesPageType.allergies: const AllergiesPage(),
        FoodPreferencesPageType.unwantedFoods: const UnwantedFoodsPage(),
        FoodPreferencesPageType.foodsToAvoid: const FoodsToAvoidPage(),
        FoodPreferencesPageType.environment: const EnvironmentPreferencesPage(),
      };

  List<FoodPreferencesPageType> get pageTypes => pages.keys.toList();

  List<Widget> get pageWidgets => pages.values.toList();

  FoodPreferencesPageType get currentPageType => pageTypes[_currentPageIndex];

  Future<void> nextPage() async {
    if (!isLastPage) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> previousPage() async {
    if (!isFirstPage) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPage(int index) {
    if (index >= 0 && index < pageCount) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
