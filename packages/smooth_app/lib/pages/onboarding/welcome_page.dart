import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

/// Welcome page for first time users.
class WelcomePage extends StatelessWidget {
  const WelcomePage();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final TextStyle headlineStyle =
        Theme.of(context).textTheme.headline2!.apply(color: Colors.white);
    final TextStyle bodyTextStyle =
        Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white);
    // Side padding is 8% of total width.
    double sidePadding(double screenWidth) => screenWidth * 0.08;

    return Scaffold(
      body: Stack(children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sidePadding(screenSize.width),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Spacer(flex: 1),
              Flexible(
                flex: 4,
                child: Text(appLocalizations.whatIsOff, style: headlineStyle),
              ),
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: SMALL_SPACE),
                      child: Text(
                        appLocalizations.country_chooser_label,
                        style: bodyTextStyle,
                      ),
                    ),
                    const CountrySelector(),
                    Padding(
                      padding: const EdgeInsets.only(left: SMALL_SPACE),
                      child: Text(
                        appLocalizations.country_selection_explanation,
                        style: bodyTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: NextButton(OnboardingPage.WELCOME),
          ),
        ),
      ]),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    );
  }
}
