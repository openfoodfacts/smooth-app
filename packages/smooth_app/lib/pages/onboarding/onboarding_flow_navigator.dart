import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/onboarding/sample_product_page.dart';
import 'package:smooth_app/pages/onboarding/scan_example.dart';
import 'package:smooth_app/pages/onboarding/welcome_page.dart';
import 'package:smooth_app/pages/page_manager.dart';

enum OnboardingPage {
  NOT_STARTED,
  WELCOME,
  SCAN_EXAMPLE,
  PRODUCT_EXAMPLE,
  ONBOARDING_COMPLETE,
}

/// Decide which page to take the user to.
class OnboardingFlowNavigator {
  OnboardingFlowNavigator(this._userPreferences);

  final UserPreferences _userPreferences;

  static OnboardingPage getNextPage(OnboardingPage currentPage) {
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
        return OnboardingPage.WELCOME;
      case OnboardingPage.WELCOME:
        return OnboardingPage.SCAN_EXAMPLE;
      case OnboardingPage.SCAN_EXAMPLE:
        return OnboardingPage.PRODUCT_EXAMPLE;
      case OnboardingPage.PRODUCT_EXAMPLE:
        return OnboardingPage.ONBOARDING_COMPLETE;
      case OnboardingPage.ONBOARDING_COMPLETE:
        return OnboardingPage.ONBOARDING_COMPLETE;
    }
  }

  static OnboardingPage _getPrevPage(OnboardingPage currentPage) {
    switch (currentPage) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.WELCOME:
        return OnboardingPage.NOT_STARTED;
      case OnboardingPage.SCAN_EXAMPLE:
        return OnboardingPage.WELCOME;
      case OnboardingPage.PRODUCT_EXAMPLE:
        return OnboardingPage.SCAN_EXAMPLE;
      case OnboardingPage.ONBOARDING_COMPLETE:
        return OnboardingPage.PRODUCT_EXAMPLE;
    }
  }

  void navigateToPage(BuildContext context, OnboardingPage page) {
    _userPreferences.setLastVisitedOnboardingPage(page);
    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => getPageWidget(context, page),
      ),
    );
  }

  Widget getPageWidget(BuildContext context, OnboardingPage page) {
    switch (page) {
      case OnboardingPage.NOT_STARTED:
      case OnboardingPage.WELCOME:
        return const WelcomePage();
      case OnboardingPage.SCAN_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
            context, page, const ScanExample());
      case OnboardingPage.PRODUCT_EXAMPLE:
        return _wrapWidgetInCustomBackNavigator(
            context, page, SampleProductPage());
      case OnboardingPage.ONBOARDING_COMPLETE:
        return PageManager();
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
                  navigateToPage(context, _getPrevPage(currentPage)),
            ),
          ),
        ),
      ),
    );
  }
}
