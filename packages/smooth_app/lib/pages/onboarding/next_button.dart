import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
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
    required this.nextKey,
  });

  final OnboardingPage currentPage;
  final Key nextKey;

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
    final OnboardingPage previousPage = currentPage.getPrevPage();
    return OnboardingBottomBar(
      startButton: previousPage.isOnboardingNotStarted()
          ? null
          : OnboardingBottomIcon(
              onPressed: () async => navigator.navigateToPage(
                context,
                previousPage,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              icon: ConstantIcons.instance.getBackIcon(),
              iconPadding: Platform.isIOS || Platform.isMacOS
                  ? const EdgeInsetsDirectional.only(end: 2.0)
                  : EdgeInsets.zero,
            ),
      endButton: OnboardingBottomButton(
        onPressed: () async {
          await OnboardingLoader(localDatabase)
              .runAtNextTime(currentPage, context);
          //ignore: use_build_context_synchronously
          await navigator.navigateToPage(
            context,
            currentPage.getNextPage(),
          );
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        label: appLocalizations.next_label,
        nextKey: nextKey,
      ),
      backgroundColor: backgroundColor,
    );
  }
}
