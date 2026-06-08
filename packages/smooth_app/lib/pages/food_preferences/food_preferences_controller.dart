import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

class FoodPreferencesController extends ChangeNotifier {
  FoodPreferencesController({
    required List<AttributeGroup> attributeGroups,
    this.showIntroduction = true,
    this.showSummary = true,
  }) : _attributeGroups = attributeGroups {
    _pageController = PageController();
  }

  late final PageController _pageController;
  final List<AttributeGroup> _attributeGroups;
  final bool showIntroduction;
  final bool showSummary;

  int _currentPageIndex = 0;

  PageController get pageController => _pageController;

  int get currentPageIndex => _currentPageIndex;

  List<AttributeGroup> get attributeGroups => _attributeGroups;

  int get pageCount {
    int count = _attributeGroups.length;
    if (showIntroduction) {
      count++;
    }
    if (showSummary) {
      count++;
    }
    return count;
  }

  bool get isFirstPage => _currentPageIndex == 0;
  bool get isLastPage => _currentPageIndex == pageCount - 1;
  double get progress => pageCount > 0 ? (currentPageIndex + 1) / pageCount : 0;

  bool get isIntroductionPage => showIntroduction && _currentPageIndex == 0;

  bool get isSummaryPage => showSummary && _currentPageIndex == pageCount - 1;

  AttributeGroup? get currentAttributeGroup {
    final int? groupIndex = _getAttributeGroupIndexForPage(_currentPageIndex);
    if (groupIndex == null) {
      return null;
    }
    return _attributeGroups[groupIndex];
  }

  int? _getAttributeGroupIndexForPage(int pageIndex) {
    int adjustedIndex = pageIndex;
    if (showIntroduction) {
      if (pageIndex == 0) {
        return null; // Introduction page
      }
      adjustedIndex--;
    }
    if (showSummary && pageIndex == pageCount - 1) {
      return null; // Summary page
    }
    if (adjustedIndex >= 0 && adjustedIndex < _attributeGroups.length) {
      return adjustedIndex;
    }
    return null;
  }

  int getPageIndexForGroupIndex(int groupIndex) {
    int pageIndex = groupIndex;
    if (showIntroduction) {
      pageIndex++;
    }
    return pageIndex;
  }

  AttributeGroup? getAttributeGroupAtIndex(int index) {
    final int? groupIndex = _getAttributeGroupIndexForPage(index);
    if (groupIndex == null) {
      return null;
    }
    return _attributeGroups[groupIndex];
  }

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
        duration: SmoothAnimationsDuration.medium,
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
