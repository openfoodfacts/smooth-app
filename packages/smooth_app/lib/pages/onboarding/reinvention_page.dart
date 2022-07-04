import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Onboarding page: "reinvention"
class ReinventionPage extends StatelessWidget {
  const ReinventionPage(this.backgroundColor);

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    const double muchTooBigFontSize = 150;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextStyle headlineStyle = Theme.of(context)
        .textTheme
        .headline2!
        .copyWith(fontSize: muchTooBigFontSize);
    final Size screenSize = MediaQuery.of(context).size;

    return SmoothScaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 30,
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
                Flexible(
                  flex: 15,
                  child: SvgPicture.asset(
                    'assets/onboarding/birthday-cake.svg',
                  ),
                ),
                Flexible(
                  flex: 30,
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
                Flexible(
                  flex: 25,
                  child: SvgPicture.asset(
                    'assets/onboarding/title.svg',
                  ),
                ),
                SvgPicture.asset(
                  // supposed to be a square or something like that
                  // at least not too tall
                  'assets/onboarding/reinvention.svg',
                  width: screenSize.width,
                ),
              ],
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
      ),
    );
  }
}
