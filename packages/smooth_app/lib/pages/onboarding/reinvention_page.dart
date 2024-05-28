import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

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
        .displayMedium!
        .copyWith(fontSize: muchTooBigFontSize);
    final Size screenSize = MediaQuery.of(context).size;
    final double animHeight = 352.0 * screenSize.width / 375.0;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              top: screenSize.height * 0.75,
              child: _Background(
                screenWidth: screenSize.width,
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: RepaintBoundary(
                child: SizedBox(
                  width: screenSize.width,
                  height: animHeight,
                  child: const RiveAnimation.asset(
                    'assets/onboarding/onboarding.riv',
                    artboard: 'Reinvention',
                    animations: <String>['Loop'],
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              bottom: animHeight - 20.0,
              child: Column(
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
                      package: AppHelper.APP_PACKAGE,
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
                      package: AppHelper.APP_PACKAGE,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: SafeArea(
                bottom: !Platform.isIOS,
                child: const NextButton(
                  OnboardingPage.REINVENTION,
                  backgroundColor: null,
                  nextKey: Key('nextAfterReinvention'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({required this.screenWidth});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: RepaintBoundary(
        child: Stack(
          children: <Widget>[
            AnimatedPositioned(
              bottom: 0.0,
              right: 0.0,
              width: screenWidth * 0.808,
              duration: SmoothAnimationsDuration.short,
              child: SvgPicture.asset(
                'assets/onboarding/hill_end.svg',
                fit: BoxFit.fill,
              ),
            ),
            AnimatedPositioned(
              bottom: 0.0,
              left: 0.0,
              width: screenWidth * 0.855,
              duration: SmoothAnimationsDuration.short,
              child: SvgPicture.asset(
                'assets/onboarding/hill_start.svg',
                fit: BoxFit.fill,
              ),
            )
          ],
        ),
      ),
    );
  }
}
