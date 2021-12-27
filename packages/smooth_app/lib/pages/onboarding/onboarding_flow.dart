import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/onboarding/scan_example.dart';
import 'package:smooth_app/pages/onboarding/welcome_page.dart';
import 'package:smooth_app/pages/page_manager.dart';

enum OnboardingPage {
  NOT_STARTED,
  WELCOME,
  SCAN_EXAMPLE,
  ONBOARDING_COMPLETE,
}

/// Decide which page to take the user to.
class OnboardingFlowNavigator {
  OnboardingFlowNavigator(this._userPreferences);

  final Future<UserPreferences> _userPreferences;

  void start(BuildContext context) {
    _userPreferences.then((UserPreferences prefs) =>
        navigateToNextPage(context, prefs.lastVisitedOnboardingPage));
  }

  void navigateToNextPage(BuildContext context, OnboardingPage currentPage) {
    _userPreferences.then((UserPreferences prefs) {
      prefs.setLastVisitedOnboardingPage(currentPage);
      Navigator.push<Widget>(
        context,
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) =>
              _nextPageWidget(context, currentPage),
        ),
      );
    });
  }

  Widget _nextPageWidget(BuildContext context, OnboardingPage currentPage) {
    Widget nextPageWidget;
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
        // First screen, doesn't have a back navigation button.
        nextPageWidget = const WelcomePage();
        break;
      case OnboardingPage.WELCOME:
        nextPageWidget = _wrapWidgetInCustomBackNavigator(
            context, currentPage, const ScanExample());
        break;
      case OnboardingPage.SCAN_EXAMPLE:
      case OnboardingPage.ONBOARDING_COMPLETE:
        nextPageWidget = PageManager();
    }
    return nextPageWidget;
  }

  OnboardingPage _getPrevPage(OnboardingPage currentPage) {
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.WELCOME:
        return OnboardingPage.NOT_STARTED;
      case OnboardingPage.SCAN_EXAMPLE:
        return OnboardingPage.WELCOME;
      case OnboardingPage.ONBOARDING_COMPLETE:
        return OnboardingPage.SCAN_EXAMPLE;
    }
  }

  Widget _wrapWidgetInCustomBackNavigator(
      BuildContext context, OnboardingPage currentPage, Widget widget) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: widget,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                navigateToNextPage(context, _getPrevPage(currentPage)),
          ),
        ),
      ),
    );
  }
}
