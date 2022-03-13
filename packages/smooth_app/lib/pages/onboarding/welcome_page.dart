import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

/// Welcome page for first time users.
class WelcomePage extends StatelessWidget {
  const WelcomePage();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final TextStyle headlineStyle =
        Theme.of(context).textTheme.headline2!.apply(color: Colors.white);
    final TextStyle bodyTextStyle =
        Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white);
    // Side padding is 8% of total width.
    final double sidePadding = MediaQuery.of(context).size.width * .08;

    return Scaffold(
      body: Stack(children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sidePadding,
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
                    CountrySelector(
                      initialCountryCode: WidgetsBinding
                          .instance?.window.locale.countryCode
                          ?.toLowerCase(),
                      padding: const EdgeInsets.only(
                        top: MEDIUM_SPACE,
                        bottom: LARGE_SPACE,
                      ),
                      inputDecoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 235, 235, 235)),
                          borderRadius: ROUNDED_BORDER_RADIUS,
                        ),
                        filled: Theme.of(context).colorScheme.brightness ==
                            Brightness.light,
                        fillColor: const Color.fromARGB(255, 235, 235, 235),
                      ),
                    ),
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
