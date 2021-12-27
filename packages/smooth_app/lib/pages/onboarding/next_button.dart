import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_constants.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/onboarding/scan_example.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

/// Next button showed at the bottom of the onboarding flow.
class NextButton extends StatelessWidget {
  const NextButton(this.currentPage);

  final OnboardingPage currentPage;
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: VERY_LARGE_SPACE,
        horizontal: sidePadding(
          screenSize.width,
        ),
      ),
      child: Row(children: <Widget>[
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: SmoothTheme.getColor(
                Theme.of(context).colorScheme,
                SmoothTheme.MATERIAL_COLORS[SmoothTheme.COLOR_TAG_BLUE]!,
                ColorDestination.BUTTON_BACKGROUND,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SMALL_SPACE)),
              primary: Colors.white,
            ),
            onPressed: () {
              OnboardingFlowNavigator(UserPreferences.getUserPreferences())
                  .navigateToNextPage(context, currentPage);
            },
            child: Text(
              appLocalizations.next_label,
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .apply(color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }
}
