import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/onboarding/next_button.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Welcome page for first time users.
class WelcomePage extends StatelessWidget {
  const WelcomePage(this.backgroundColor);

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final TextStyle headlineStyle = theme.textTheme.displayMedium!.wellSpaced;
    final TextStyle bodyTextStyle = theme.textTheme.bodyLarge!.wellSpaced;
    final Size screenSize = MediaQuery.sizeOf(context);

    return SmoothScaffold(
      backgroundColor: backgroundColor,
      brightness: Brightness.dark,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: Platform.isAndroid,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
                child: ListView(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: screenSize.height * .05),
                        SvgPicture.asset(
                          'assets/onboarding/title.svg',
                          height: screenSize.height * .10,
                          package: AppHelper.APP_PACKAGE,
                        ),
                        SvgPicture.asset(
                          'assets/onboarding/globe.svg',
                          height: screenSize.height * .20,
                          package: AppHelper.APP_PACKAGE,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                              top: SMALL_SPACE),
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          appLocalizations.onboarding_country_chooser_label,
                          style: bodyTextStyle,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: MEDIUM_SPACE),
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.fromBorderSide(
                                BorderSide(
                                  color: theme.colorScheme.inversePrimary,
                                  width: 1,
                                ),
                              ),
                              borderRadius: ROUNDED_BORDER_RADIUS,
                              color: theme.colorScheme.onPrimary,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: CountrySelector(
                                forceCurrencyChange: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SMALL_SPACE,
                                ),
                                inkWellBorderRadius: ROUNDED_BORDER_RADIUS,
                                icon: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: ROUNDED_BORDER_RADIUS,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                                textStyle: TextStyle(color: theme.primaryColor),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: VERY_SMALL_SPACE,
                          ),
                          child: Text(
                            appLocalizations.country_selection_explanation,
                            style: bodyTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            NextButton(
              OnboardingPage.WELCOME,
              backgroundColor: backgroundColor,
              nextKey: const Key('nextAfterWelcome'),
            ),
          ],
        ),
      ),
    );
  }
}
