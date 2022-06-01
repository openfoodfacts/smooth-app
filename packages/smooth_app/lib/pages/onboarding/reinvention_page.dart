import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

/// Onboarding page: "reinvention"
class ReinventionPage extends StatelessWidget {
  const ReinventionPage();

  @override
  Widget build(BuildContext context) {
    const double muchTooBigFontSize = 150;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextStyle headlineStyle = Theme.of(context)
        .textTheme
        .headline2!
        .copyWith(fontSize: muchTooBigFontSize);
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.red,
      body: Stack(
        children: <Widget>[
          SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: SvgPicture.asset(
              'assets/onboarding/reinvention.svg',
              width: screenSize.width,
              height: screenSize.height,
              // TODO(monsieurtanuki): I had to stretch the svg, it would be better to extract just the bottom half and fill the top with background color
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height * .5, // only top half of the screen
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: screenSize.height * .15,
                    child: Padding(
                      padding: const EdgeInsets.all(SMALL_SPACE),
                      child: Center(
                        child: AutoSizeText(
                          appLocalizations.onboarding_reinventing_text1,
                          style: headlineStyle,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * .07,
                    child: SvgPicture.asset(
                      'assets/onboarding/birthday-cake.svg',
                      height: screenSize.height * .07,
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * .15,
                    child: Padding(
                      padding: const EdgeInsets.all(SMALL_SPACE),
                      child: Center(
                        child: AutoSizeText(
                          appLocalizations.onboarding_reinventing_text2,
                          style: headlineStyle,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/onboarding/title.svg',
                    height: screenSize.height * .10,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            child: NextButton(
              OnboardingPage.REINVENTION,
              backgroundColor: null,
            ),
          ),
        ],
      ),
    );
  }
}
