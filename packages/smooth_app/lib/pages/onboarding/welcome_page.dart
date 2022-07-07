import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Welcome page for first time users.
class WelcomePage extends StatelessWidget {
  const WelcomePage(this.backgroundColor);

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextStyle headlineStyle = Theme.of(context).textTheme.headline2!;
    final TextStyle bodyTextStyle = Theme.of(context).textTheme.bodyText1!;
    final Size screenSize = MediaQuery.of(context).size;

    return SmoothScaffold(
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenSize.height * .05),
                SvgPicture.asset(
                  'assets/onboarding/title.svg',
                  height: screenSize.height * .10,
                ),
                SvgPicture.asset(
                  'assets/onboarding/globe.svg',
                  height: screenSize.height * .20,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
                  child: SizedBox(
                    height: screenSize.height * .15,
                    child: AutoSizeText(
                      appLocalizations.whatIsOff,
                      style: headlineStyle,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  appLocalizations.country_chooser_label,
                  style: bodyTextStyle,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
                  child: Ink(
                    decoration: BoxDecoration(
                      border: const Border.fromBorderSide(
                        BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      borderRadius: ANGULAR_BORDER_RADIUS,
                      color: Theme.of(context).cardColor,
                    ),
                    child: CountrySelector(
                      initialCountryCode: WidgetsBinding
                          .instance.window.locale.countryCode
                          ?.toLowerCase(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: SMALL_SPACE,
                    bottom: VERY_SMALL_SPACE,
                  ),
                  child: Text(
                    appLocalizations.country_selection_explanation,
                    style: bodyTextStyle,
                  ),
                ),
              ],
            ),
          ),
          NextButton(
            OnboardingPage.WELCOME,
            backgroundColor: backgroundColor,
          ),
        ],
      ),
    );
  }
}
