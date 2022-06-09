import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/onboarding/onboarding_bottom_bar.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Next button showed at the bottom of the onboarding flow.
class NextButton extends StatelessWidget {
  // we need a Key for the test/screenshots
  const NextButton(
    this.currentPage, {
    required this.backgroundColor,
  }) : super(key: const Key('next'));

  final OnboardingPage currentPage;

  /// Color of the background where we put the buttons.
  ///
  /// If null, transparent background and no visible divider.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final OnboardingFlowNavigator navigator =
        OnboardingFlowNavigator(userPreferences);
    final OnboardingPage previousPage =
        OnboardingFlowNavigator.getPrevPage(currentPage);
    return OnboardingBottomBar(
      leftButton: previousPage == OnboardingPage.NOT_STARTED
          ? null
          : OnboardingBottomIcon(
              onPressed: () => navigator.navigateToPage(
                context,
                previousPage,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              icon: ConstantIcons.instance.getBackIcon(),
            ),
      rightButton: OnboardingBottomButton(
        onPressed: () async {
          await OnboardingLoader(localDatabase)
              .runAtNextTime(currentPage, context);
          //ignore: use_build_context_synchronously
          navigator.navigateToPage(
            context,
            OnboardingFlowNavigator.getNextPage(currentPage),
          );
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        label: appLocalizations.next_label,
      ),
      backgroundColor: backgroundColor,
    );
  }
}
