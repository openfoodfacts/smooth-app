import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

/// Example explanation on how to scan a product.
class ScanExample extends StatelessWidget {
  const ScanExample();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 225, 208, 208),
          height: screenSize.height,
        ),
        Column(
          children: [
            Flexible(
              flex: 8,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -screenSize.height / 8,
                    left: screenSize.width / 16,
                    child: Transform.rotate(
                      angle: -0.22828907, // 13.08 degrees
                      child: Container(
                        color: Color.fromARGB(255, 3, 129, 65),
                        width: screenSize.width,
                        height: screenSize.height / 2,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenSize.height / 8,
                    left: screenSize.width / 8,
                    child: SvgPicture.asset(
                      'assets/onboarding/scan_example.svg',
                      width: screenSize.width / 2,
                      height: screenSize.height / 4,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(
                    left: screenSize.width / 10, right: MEDIUM_SPACE),
                child: Text(
                  appLocalizations.offUtility,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .apply(color: Color.fromARGB(255, 51, 51, 51)),
                ),
              ),
            ),
            const Spacer(flex: 2),
            Flexible(
              flex: 1,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width / 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/cache/ecoscore-a-no-bg.svg',
                      width: 80,
                    ),
                    SvgPicture.asset(
                      'assets/cache/nutriscore-a-no-bg.svg',
                      width: 80,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
        const Positioned(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: NextButton(OnboardingPage.SCAN_EXAMPLE),
          ),
        ),
      ],
    );
  }
}
