import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_controller.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preferences_navigation_bar.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preferences_progress_indicator.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class FoodPreferencesPage extends StatefulWidget {
  const FoodPreferencesPage({super.key});

  @override
  State<FoodPreferencesPage> createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
  late final FoodPreferencesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FoodPreferencesController();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  String _getPageTitle(AppLocalizations appLocalizations) {
    switch (_controller.currentPageType) {
      case FoodPreferencesPageType.introduction:
        return appLocalizations.food_preferences_page_title_introduction;
      case FoodPreferencesPageType.diets:
        return appLocalizations.food_preferences_page_title_diets;
      case FoodPreferencesPageType.allergies:
        return appLocalizations.food_preferences_page_title_allergies;
      case FoodPreferencesPageType.unwantedFoods:
        return appLocalizations.food_preferences_page_title_unwanted_foods;
      case FoodPreferencesPageType.foodsToAvoid:
        return appLocalizations.food_preferences_page_title_foods_to_avoid;
      case FoodPreferencesPageType.environment:
        return appLocalizations.food_preferences_page_title_environment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothScaffold(
      appBar: AppBar(
        leading: EMPTY_WIDGET,
        leadingWidth: 0.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        backgroundColor: theme.colorScheme.secondary,
        toolbarHeight: 120.0,
        title: Column(
          spacing: VERY_LARGE_SPACE,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: FoodPreferencesProgressIndicator(
                    progress: _controller.progress,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text(_getPageTitle(appLocalizations))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _controller.pageController,
              onPageChanged: _controller.onPageChanged,
              children: _controller.pageWidgets,
            ),
          ),
          FoodPreferencesNavigationBar(
            isFirstPage: _controller.isFirstPage,
            isLastPage: _controller.isLastPage,
            onPrevious: _controller.previousPage,
            onNext: _controller.nextPage,
            onFinish: _onFinish,
          ),
        ],
      ),
    );
  }

  void _onFinish() {
    Navigator.of(context).pop();
  }
}
