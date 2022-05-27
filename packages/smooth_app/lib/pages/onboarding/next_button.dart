import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Next button showed at the bottom of the onboarding flow.
class NextButton extends StatelessWidget {
  // we need a Key for the test/screenshots
  const NextButton(
    this.currentPage, {
    this.backgroundColor,
  }) : super(key: const Key('next'));

  final OnboardingPage currentPage;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    // Side padding is 8% of total width.
    final double sidePadding = screenSize.width * .08;
    final OnboardingFlowNavigator navigator =
        OnboardingFlowNavigator(userPreferences);
    final OnboardingPage previousPage =
        OnboardingFlowNavigator.getPrevPage(currentPage);
    return Column(
      children: <Widget>[
        Container(
          height: SMALL_SPACE,
          width: screenSize.width,
          color: LIGHT_GREY_COLOR,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: VERY_LARGE_SPACE,
            horizontal: sidePadding,
          ),
          width: screenSize.width,
          color: backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (previousPage != OnboardingPage.NOT_STARTED)
                Padding(
                  padding: const EdgeInsets.only(right: LARGE_SPACE),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      primary: Colors.white,
                      onPrimary: Colors.black,
                    ),
                    onPressed: () => navigator.navigateToPage(
                      context,
                      previousPage,
                    ),
                    child: Icon(ConstantIcons.instance.getBackIcon()),
                  ),
                ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints.tightFor(height: MINIMUM_TARGET_SIZE),
                child: ElevatedButton(
                  onPressed: () async {
                    await OnboardingLoader(localDatabase)
                        .runAtNextTime(currentPage, context);
                    //ignore: use_build_context_synchronously
                    navigator.navigateToPage(
                      context,
                      OnboardingFlowNavigator.getNextPage(currentPage),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  child: Text(
                    appLocalizations.next_label,
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
