import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

/// Example explanation on how to scan a product.
class ScanExample extends StatelessWidget {
  const ScanExample(this.backgroundColor);

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/onboarding/scan.svg',
                  height: screenSize.height * .50,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
                  child: SizedBox(
                    height: screenSize.height * .15,
                    child: AutoSizeText(
                      appLocalizations.offUtility,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .apply(color: const Color.fromARGB(255, 51, 51, 51)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          NextButton(
            OnboardingPage.SCAN_EXAMPLE,
            backgroundColor: backgroundColor,
          ),
        ],
      ),
    );
  }
}
