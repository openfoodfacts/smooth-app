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

  Widget getNextPageWidget(BuildContext context, OnboardingPage currentPage) {
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
        // First screen, doesn't have a back navigation button.
        return const WelcomePage();
        break;
      case OnboardingPage.WELCOME:
        return _wrapWidgetInCustomBackNavigator(
          context,
          currentPage,
          const ScanExample(),
        );
        break;
      case OnboardingPage.SCAN_EXAMPLE:
      case OnboardingPage.ONBOARDING_COMPLETE:
        return PageManager();
    }
  }

  void navigateToNextPage(BuildContext context, OnboardingPage currentPage) {
    _userPreferences.then((UserPreferences prefs) {
      prefs.setLastVisitedOnboardingPage(currentPage);
      Navigator.push<Widget>(
        context,
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) =>
              getNextPageWidget(context, currentPage),
        ),
      );
    });
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
      // wrap the widget in [Builder] to allow navigation on the [context].
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          body: widget,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  navigateToNextPage(context, _getPrevPage(currentPage)),
            ),
          ),
        ),
      ),
    );
  }
}
